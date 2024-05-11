if Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()

    RegisterNetEvent('ss-garage:client:SpawnVehicle', function(data)
        local coords = GetFreeSpot()

        if coords == nil then return QBCore.Functions.Notify(Locales[Config.Language]["noparkingspace"], 'error') end

        QBCore.Functions.TriggerCallback('ss-garage:qb-spawnVehicle', function(netId, properties, plate)
            while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
            local veh = NetworkGetEntityFromNetworkId(netId)
            local stats = { engine = data.engine, body = data.body, fuel = data.fuel }
            SetVehicleProperties(veh, properties)
            doCarDamage(veh, stats, properties)

            exports[Config.QBCore.FuelResource]:SetFuel(veh, data.fuel)
            TriggerServerEvent('ss-garage:server:qb-updateState', plate, 0)
            TriggerEvent('vehiclekeys:client:SetOwner', plate)

            if Config.WarpIntoVehicle then
                TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
            end
        end, data.plate, data.vehicle, coords)
    end)

    RegisterNetEvent('ss-garage:client:PayForImpound', function(data)
        QBCore.Functions.TriggerCallback('ss-garage:qb-payForImpound', function(success)
            if success then
                TriggerEvent('ss-garage:client:SpawnVehicle', data.vehicle)
            end
        end, data)
    end)

    RegisterNetEvent('ss-garage:client:ParkVehicle', function(vehicle, plate, vehProps, garage)
        local body = math.ceil(GetVehicleBodyHealth(vehicle))
        local engine = math.ceil(GetVehicleEngineHealth(vehicle))
        local fuel = exports[Config.QBCore.FuelResource]:GetFuel(vehicle)
        QBCore.Functions.TriggerCallback('ss-garage:qb-parkVehicle', function(success)
            if success then
                DeleteVehicle(vehicle)
                QBCore.Functions.Notify(Locales[Config.Language]["vparked"], 'success')
            else
                QBCore.Functions.Notify(Locales[Config.Language]["notowned"], 'error')
            end
        end, plate, vehProps, garage, fuel, engine, body)
    end)

    function QBCore:OpenGarage(id)
        local garage = Config.Garages[id]
        QBCore.Functions.TriggerCallback('ss-garage:qb-getvehicles', function(vehicles, errorMessage)
            if vehicles then
                SendNUIMessage({
                    action = "open",
                    vehicles = vehicles,
                    garages = Config.Garages,
                    garage = id,
                    locale = Locales[Config.Language]["UI"],
                })
                SetNuiFocus(true, true)
            else
                if errorMessage then
                    QBCore.Functions.Notify(errorMessage, 'error')
                else
                    QBCore.Functions.Notify(Locales[Config.Language]["novehicles"], 'error')
                end
            end
        end, id, garage.type, Config.VehicleClass[garage.category])        
    end

    function ZoneExists(zoneName)
        for _, zone in ipairs(garageZones) do
            if zone.name == zoneName then
                return true
            end
        end
        return false
    end

    function RemoveZone(zoneName)
        local removedZone = comboZone:RemoveZone(zoneName)
        if removedZone then
            removedZone:destroy()
        end
        for index, zone in ipairs(garageZones) do
            if zone.name == zoneName then
                table.remove(garageZones, index)
                break
            end
        end
    end

    RegisterNetEvent('qb-garages:client:setHouseGarage', function(house, hasKey) -- event sent periodically from housing
        if not house then return end
        local formattedHouseName = string.gsub(string.lower(house), ' ', '')
        if Config.Garages[formattedHouseName] then
            if hasKey and not ZoneExists(formattedHouseName) then
                CreateZone(formattedHouseName, Config.Garages[formattedHouseName], 'house')
            elseif not hasKey and ZoneExists(formattedHouseName) then
                RemoveZone(formattedHouseName)
            end
        else
            QBCore.Functions.TriggerCallback('qb-garages:server:getHouseGarage', function(garageInfo) -- create garage if not exist
                local garageCoords = json.decode(garageInfo.garage)
                if garageCoords then
                    Config.Garages[formattedHouseName] = {
                        label = house,
                        coords = vector3(garageCoords.x, garageCoords.y, garageCoords.z),
                        spawns = {
                            vector4(garageCoords.x, garageCoords.y, garageCoords.z, garageCoords.w or garageCoords.h)
                        },
                        label = garageInfo.label,
                        type = 'house',
                        category = 'all'
                    }
                    TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
                end
            end, house)
        end
    end)
    
    RegisterNetEvent('qb-garages:client:houseGarageConfig', function(houseGarages)
        for _, garageConfig in pairs(houseGarages) do
            local formattedHouseName = string.gsub(string.lower(garageConfig.label), ' ', '')
            if garageConfig.takeVehicle and garageConfig.takeVehicle.x and garageConfig.takeVehicle.y and garageConfig.takeVehicle.z and garageConfig.takeVehicle.w then
                Config.Garages[formattedHouseName] = {
                    coords = vector3(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z),
                    spawns = {
                        vector4(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z, garageConfig.takeVehicle.w)
                    },
                    label = garageConfig.label,
                    type = 'house',
                    category = 'all'
                }
            end
        end
        TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
    end)
    
    RegisterNetEvent('qb-garages:client:addHouseGarage', function(house, garageInfo) -- event from housing on garage creation
        local formattedHouseName = string.gsub(string.lower(house), ' ', '')
        Config.Garages[formattedHouseName] = {
            coords = vector3(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z),
            spawns = {
                vector4(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z, garageInfo.takeVehicle.w)
            },
            label = garageInfo.label,
            type = 'house',
            category = 'all'
        }
        TriggerServerEvent('qb-garages:server:syncGarage', Config.Garages)
    end)

    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        CreateBlipsZones()
    end)
end