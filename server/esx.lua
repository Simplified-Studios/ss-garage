if Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()

    AddEventHandler('onResourceStart', function(resource)
        if resource == GetCurrentResourceName() then
            MySQL.Async.execute('UPDATE owned_vehicles SET stored = 1 WHERE stored = 0')
        end
    end)

    local function Round(value, numDecimalPlaces)
        if not numDecimalPlaces then return math.floor(value + 0.5) end
        local power = 10 ^ numDecimalPlaces
        return math.floor((value * power) + 0.5) / (power)
    end

    RegisterNetEvent('ss-garage:esx-setState', function(plate, state)
        MySQL.Async.execute('UPDATE owned_vehicles SET stored = @state WHERE plate = @plate', { ['@plate'] = plate, ['@state'] = state })
    end)

    ESX.RegisterServerCallback('ss-garage:esx-getvehicles', function(source, cb, garage, _type, category)
        local xPlayer = ESX.GetPlayerFromId(source)

        local query = 'SELECT * FROM owned_vehicles WHERE owner = @owner'
        local params = { ['@owner'] = xPlayer.identifier }

        if _type == 'depot' then
            query = query .. ' AND stored = 2'
        elseif Config.RealisticGarage then
            query = query .. ' AND parking = @parking AND stored = 1'
            params['@parking'] = garage
        end

        MySQL.query(query, params, function(result)
            cb(result)
        end)
    end)

    ESX.RegisterServerCallback('ss-garage:esx-spawnVehicle', function(source, cb, plate, vehicle, coords)
        local xPlayer = ESX.GetPlayerFromId(source)

        local isOwned = exports['oxmysql']:fetchSync('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ? AND stored = 1', { xPlayer.identifier, plate })

        if OutsideVehicles[plate] and DoesEntityExist(OutsideVehicles[plate].entity) then
            return xPlayer.showNotification(Locales[Config.Language]['vehout'])
        end

        if isOwned[1] then
            ESX.OneSync.SpawnVehicle(vehicle, vector3(coords.x, coords.y, coords.z), coords.w, isOwned[1].vehicle, function(netid)
                local vehicle = NetworkGetEntityFromNetworkId(netid)
                Wait(300)
                SetVehicleNumberPlateText(vehicle, plate)
                TaskWarpPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
                OutsideVehicles[plate] = { netID = netid, entity = vehicle }
                cb(netid, isOwned[1].vehicle, plate)
            end)
        end
    end)

    ESX.RegisterServerCallback('ss-garage:esx-payForImpound', function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)

        local isOwned = exports['oxmysql']:fetchSync('SELECT * FROM owned_vehicles WHERE owner = ? AND stored = 2', { xPlayer.identifier })

        if isOwned[1] then
            local price = tonumber(data.vehicle.impoundPrice)

            if xPlayer.getMoney() >= price then
                xPlayer.removeMoney(price)
                MySQL.Async.execute('UPDATE owned_vehicles SET stored = 1 WHERE owner = @owner AND stored = 2', { ['@owner'] = xPlayer.identifier })
                cb(true)
            else
                xPlayer.showNotification(Locales[Config.Language]['unotenough'])
                cb(false)
            end
        else
            xPlayer.showNotification(Locales[Config.Language]['vnotfound'])
            cb(false)
        end
    end)

    ESX.RegisterServerCallback('ss-garage:esx-parkVehicle', function(source, cb, plate, vehicleProps, garage)
        local xPlayer = ESX.GetPlayerFromId(source)

        local isOwned = exports['oxmysql']:fetchSync('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?', { xPlayer.identifier, plate })

        if not isOwned[1] then
            return cb(false)
        end

        for key, value in pairs(vehicleProps) do
            if type(value) == "boolean" then
                vehicleProps[key] = value and 1 or 0
            end
        end

        MySQL.Async.execute('UPDATE owned_vehicles SET stored = 1, parking = @parking, vehicle = @vehicle WHERE owner = @owner AND plate = @plate', { ['@parking'] = garage, ['@vehicle'] = json.encode(vehicleProps), ['@owner'] = xPlayer.identifier, ['@plate'] = plate })
        OutsideVehicles[plate] = nil
        cb(true)
    end)

    RegisterNetEvent('ss-garage:server:SwapGarage', function(data)
        local player = ESX.GetPlayerFromId(source)

        local isOwner = exports['oxmysql']:fetchSync('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ? AND stored = 1', { player.identifier, data.vehicle.plate })

        if not isOwner[1] then
            return player.showNotification(Locales[Config.Language]['vnotfound'])
        end

        if OutsideVehicles[data.vehicle.plate] and DoesEntityExist(OutsideVehicles[data.vehicle.plate].entity) then
            return player.showNotification(Locales[Config.Language]['vehout'])
        end

        local canSwap = true

        if Config.Swapping.PayForSwap then
            if player.getMoney() >= Config.Swapping.PayAmount then
                player.removeMoney(Config.Swapping.PayAmount)
            else
                canSwap = false
                player.showNotification(Locales[Config.Language]['unotenough'])
            end
        end

        if canSwap then
            MySQL.Async.execute('UPDATE owned_vehicles SET parking = @parking WHERE owner = @owner AND plate = @plate', { ['@parking'] = data.garage, ['@owner'] = player.identifier, ['@plate'] = data.vehicle.plate })
            OutsideVehicles[data.vehicle.plate] = nil
            player.showNotification(Locales[Config.Language]['swapped'])
        end
    end)

    RegisterNetEvent('ss-garage:server:TransferVehicle', function(data)
        local player = ESX.GetPlayerFromId(source)
        local target = ESX.GetPlayerFromId(data.id)
    
        if not target then
            return player.showNotification(Locales[Config.Language]['pnotfound'])
        end
    
        if target.identifier == player.identifier then
            return player.showNotification(Locales[Config.Language]['transfer2urself'])
        end
    
        local isOwner = exports['oxmysql']:fetchSync('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ? AND stored = 1', { player.identifier, data.vehicle.plate })
    
        if not isOwner[1] then
            return player.showNotification(Locales[Config.Language]['notowned'])
        end
    
        local price = tonumber(data.price) or 0
        local canTransfer = true
    
        if price > 0 then
            if player.getMoney() < price then
                canTransfer = false
                player.showNotification(Locales[Config.Language]['pnotenough'])
                target.showNotification(Locales[Config.Language]['unotenough'])
            else
                target.removeMoney(price)
                player.addMoney(price)
            end
        end
    
        if canTransfer then
            MySQL.Async.execute('UPDATE owned_vehicles SET owner = @owner WHERE owner = @oldOwner AND plate = @plate', { ['@owner'] = target.identifier, ['@oldOwner'] = player.identifier, ['@plate'] = data.vehicle.plate })
            player.showNotification(Locales[Config.Language]['transferedvehicle'])
            target.showNotification(Locales[Config.Language]['receivedvehicle'])
        end
    end)

    RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
        TriggerClientEvent('ss-garage:client:CreateBlipsZones', player)
    end)
end