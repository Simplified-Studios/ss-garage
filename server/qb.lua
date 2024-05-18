if Config.Framework == 'qb' then
    local QBCore = exports['qb-core']:GetCoreObject()
    local vehicleClasses = {
        compacts = 0, sedans = 1, suvs = 2, coupes = 3, muscle = 4, sportsclassics = 5, sports = 6, super = 7,
        motorcycles = 8, offroad = 9, industrial = 10, utility = 11, vans = 12, cycles = 13, boats = 14,
        helicopters = 15, planes = 16, service = 17, emergency = 18, military = 19, commercial = 20, trains = 21,
        openwheel = 22
    }

    AddEventHandler('onResourceStart', function(resource)
        if resource == GetCurrentResourceName() then
            exports['oxmysql']:execute('UPDATE player_vehicles SET state = 1 WHERE state = 0', {}, function(res)
                print(('^2[ss-garage]^7 %s vehicles have been moved to garage'):format(res.affectedRows))
            end)
        end
    end)

    local function arrayToSet(array)
        local set = {}
        for _, item in ipairs(array) do
            set[item] = true
        end
        return set
    end

    local function filterVehiclesByCategory(vehicles, category)
        local filtered = {}
        local categorySet = arrayToSet(category)

        for _, vehicle in pairs(vehicles) do
            local vehicleData = QBCore.Shared.Vehicles[vehicle.vehicle]
            local vehicleCategoryString = vehicleData and vehicleData.category or 'compacts'
            local vehicleCategoryNumber = vehicleClasses[vehicleCategoryString]

            if vehicleCategoryNumber and categorySet[vehicleCategoryNumber] then
                table.insert(filtered, vehicle)
            end
        end
        return filtered
    end

    QBCore.Functions.CreateCallback('ss-garage:qb-getvehicles', function(source, cb, garage, _type, category)
        local Player = QBCore.Functions.GetPlayer(source)
        local vehicles = {}

        if Config.Garages[garage].job and Player.PlayerData.job.name ~= Config.Garages[garage].job or Config.Garages[garage].gang and Player.PlayerData.gang.name ~= Config.Garages[garage].gang then
            return cb(nil, Locales[Config.Language]["notaccess"])
        end

        local query = 'SELECT * FROM player_vehicles WHERE citizenid = ?'
        local params = { Player.PlayerData.citizenid }

        if _type == 'depot' then
            query = query .. ' AND state = 2'
        elseif Config.RealisticGarage then
            query = query .. ' AND garage = ? AND state = 1'
            table.insert(params, garage)
        end

        exports['oxmysql']:execute(query, params, function(result)
            for _, vehicleData in ipairs(result) do
                local label = QBCore.Shared.Vehicles[vehicleData.vehicle] and QBCore.Shared.Vehicles[vehicleData.vehicle].name or vehicleData.vehicle

                local price = Config.Impound.DefaultImpoundPrice

                if tonumber(vehicleData.depotprice) > 0 then
                    price = tonumber(vehicleData.depotprice)
                end

                table.insert(vehicles, {
                    plate = vehicleData.plate,
                    label = label,
                    state = vehicleData.state,
                    isImpounded = vehicleData.state == 2,
                    impoundPrice = price,
                    garage = vehicleData.garage,
                    vehicle = vehicleData.vehicle,
                    fuel = vehicleData.fuel or 100,
                    engine = vehicleData.engine or 1000,
                    body = vehicleData.body or 100,
                })
            end

            local filteredVehicles = filterVehiclesByCategory(vehicles, category)
            cb(filteredVehicles)
        end)
    end)

    QBCore.Functions.CreateCallback('qb-garages:server:getHouseGarage', function(_, cb, house)
        local houseInfo = exports['oxmysql']:fetchSync('SELECT * FROM houselocations WHERE name = ?', { house })
        cb(houseInfo)
    end)

    QBCore.Functions.CreateCallback('ss-garage:qb-spawnVehicle', function(source, cb, plate, vehicle, coords)
        local Player = QBCore.Functions.GetPlayer(source)
        local res = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND vehicle = ?', { Player.PlayerData.citizenid, plate, vehicle })
        if res[1] then
            local veh = CreateVehicleServerSetter(GetHashKey(vehicle), 'automobile', coords.x, coords.y, coords.z, coords.w)
            local netId = NetworkGetNetworkIdFromEntity(veh)
            SetVehicleNumberPlateText(veh, plate)
            local vehProps = {}
            local result = exports['oxmysql']:fetchSync('SELECT mods FROM player_vehicles WHERE citizenid = ? AND plate = ?', { Player.PlayerData.citizenid, plate })

            if result and result[1] then
                vehProps = json.decode(result[1].mods)
            end
            
            if OutsideVehicles[plate] and DoesEntityExist(OutsideVehicles[plate].entity) then
                return TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Locales[Config.Language]["vehout"], 'error')
            end
            
            OutsideVehicles[plate] = { netID = netId, entity = veh }
            cb(netId, vehProps, plate)
        end
    end)

    QBCore.Functions.CreateCallback('ss-garage:qb-payForImpound', function(source, cb, data)
        local Player = QBCore.Functions.GetPlayer(source)
        local res = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND vehicle = ?', { Player.PlayerData.citizenid, data.vehicle.plate, data.vehicle.vehicle })

        if res then
            local depotprice = Config.Impound.DefaultImpoundPrice

            if tonumber(res[1].depotprice) > 0 then
                depotprice = tonumber(res[1].depotprice)
            end

            if Player.PlayerData.money.bank >= depotprice then
                Player.Functions.RemoveMoney('bank', depotprice)
                exports['oxmysql']:execute('UPDATE player_vehicles SET state = 0, depotprice = 0 WHERE citizenid = ? AND plate = ? AND vehicle = ?', { Player.PlayerData.citizenid, data.vehicle.plate, data.vehicle.vehicle })
                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Locales[Config.Language]["impoundpaid"], 'success')
                cb(true)
            else
                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Locales[Config.Language]["unotenough"], 'error')
                cb(false)
            end
        else
            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Locales[Config.Language]["vehout"], 'error')
            cb(false)
        end
    end)

    RegisterNetEvent('ss-garage:server:SwapGarage', function(data)
        local Player = QBCore.Functions.GetPlayer(source)

        if not Player then return end

        local isOwner = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND vehicle = ? AND plate = ? AND state = 1', { Player.PlayerData.citizenid, data.vehicle.vehicle, data.vehicle.plate })

        if not isOwner[1] then
            return TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Locales[Config.Language]["notowned"], 'error')
        end

        if OutsideVehicles[data.vehicle.plate] and DoesEntityExist(OutsideVehicles[data.vehicle.plate].entity) then
            return TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Locales[Config.Language]["vehout"], 'error')
        end

        local canSwap = true

        if Config.Swapping.PayForSwap then
            if Player.PlayerData.money.bank >= Config.Swapping.PayAmount then
                Player.Functions.RemoveMoney('bank', Config.Swapping.PayAmount)
            else
                canSwap = false
                TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, Locales[Config.Language]["unotenough"], 'error')
            end
        end

        if canSwap then
            exports['oxmysql']:execute('UPDATE player_vehicles SET garage = ? WHERE citizenid = ? AND vehicle = ? AND plate = ?', { data.garage, Player.PlayerData.citizenid, data.vehicle.vehicle, data.vehicle.plate })
            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'Vehicle swapped successfully', 'success')
        end
    end)

    RegisterNetEvent('ss-garage:server:TransferVehicle', function(data)
        local player = QBCore.Functions.GetPlayer(source)
        if not player then return end
    
        local target = QBCore.Functions.GetPlayer(tonumber(data.id))
        if not target then
            TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Locales[Config.Language]["pnotfound"], 'error')
            return
        end
    
        if target.PlayerData.citizenid == player.PlayerData.citizenid then
            TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Locales[Config.Language]["transfer2urself"], 'error')
            return
        end
    
        local isOwner = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND vehicle = ? AND plate = ? AND state = 1', {player.PlayerData.citizenid, data.vehicle.vehicle, data.vehicle.plate})
    
        if not isOwner or #isOwner == 0 then
            TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Locales[Config.Language]["notowned"], 'error')
            return
        end
    
        local price = tonumber(data.price) or 0
        local canTransfer = true
    
        if price > 0 then
            if target.PlayerData.money.bank < price then
                canTransfer = false
                TriggerClientEvent('QBCore:Notify', target.PlayerData.source, Locales[Config.Language]["unotenough"], 'error')
            else
                target.Functions.RemoveMoney('bank', price)
                player.Functions.AddMoney('bank', price)
            end
        end
    
        if canTransfer then
            exports['oxmysql']:execute('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE citizenid = ? AND vehicle = ? AND plate = ?', {target.PlayerData.citizenid, target.PlayerData.license, player.PlayerData.citizenid, data.vehicle.vehicle, data.vehicle.plate})
            TriggerClientEvent('QBCore:Notify', player.PlayerData.source, Locales[Config.Language]["transferedvehicle"], 'success')
            TriggerClientEvent('QBCore:Notify', target.PlayerData.source, Locales[Config.Language]["receivedvehicle"], 'success')
        end
    end)

    RegisterNetEvent('ss-garage:server:qb-updateState', function(plate, state)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end

        local isOwner = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {Player.PlayerData.citizenid, plate})

        if isOwner[1] then
            exports['oxmysql']:execute('UPDATE player_vehicles SET state = ? WHERE citizenid = ? AND plate = ?', {state, Player.PlayerData.citizenid, plate})
        end
    end)

    QBCore.Functions.CreateCallback('ss-garage:qb-parkVehicle', function(source, cb, plate, vehProps, garage, fuel, engine, body)
        local Player = QBCore.Functions.GetPlayer(source)
    
        exports['oxmysql']:fetch('SELECT citizenid FROM player_vehicles WHERE plate = ?', {plate}, function(result)
            if result[1] then
                local isOwner = result[1].citizenid
                if isOwner == Player.PlayerData.citizenid then
                    for key, value in pairs(vehProps) do
                        if type(value) == "boolean" then
                            vehProps[key] = value and 1 or 0
                        end
                    end
    
                    exports['oxmysql']:execute('UPDATE player_vehicles SET state = ?, garage = ?, mods = ?, fuel = ?, body = ?, engine = ? WHERE plate = ?', {1, garage, json.encode(vehProps), fuel, body, engine, plate})
    
                    OutsideVehicles[plate] = nil
                    cb(true)
                else
                    print('not the owner')
                    print(isOwner, Player.PlayerData.citizenid)
                    cb(false)
                end
            else
                print('Plate not found:', plate)
                cb(false)
            end
        end)
    end)

    QBCore.Functions.CreateCallback('qb-garages:server:GetPlayerVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Vehicles = {}

    MySQL.rawExecute('SELECT * FROM player_vehicles WHERE citizenid = ?', { Player.PlayerData.citizenid }, function(result)
        if result[1] then
            for _, v in pairs(result) do
                local VehicleData = QBCore.Shared.Vehicles[v.vehicle]

                local VehicleGarage = "Error"
                if v.garage ~= nil then
                    if Config.Garages[v.garage] ~= nil then
                        VehicleGarage = Config.Garages[v.garage].label
                    else
                        VehicleGarage = "House Garage"
                    end
                end

                local stateTranslation
                if v.state == 0 then
                    stateTranslation = "Out"
                elseif v.state == 1 then
                    stateTranslation = "Parked"
                elseif v.state == 2 then
                    stateTranslation = "Impound"
                end

                local fullname
                if VehicleData and VehicleData['brand'] then
                    fullname = VehicleData['brand'] .. ' ' .. VehicleData['name']
                else
                    fullname = VehicleData and VehicleData['name'] or 'Unknown Vehicle'
                end

                Vehicles[#Vehicles + 1] = {
                    fullname = fullname,
                    brand = VehicleData and VehicleData['brand'] or '',
                    model = VehicleData and VehicleData['name'] or '',
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = stateTranslation,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body
                }
            end
            cb(Vehicles)
        else
            cb(nil)
        end
    end)
end)

    RegisterNetEvent('qb-garages:server:syncGarage', function(updatedGarages)
        Config.Garages = updatedGarages
    end)

    exports('GetGarages', function()
        return Config.Garages
    end)
end
