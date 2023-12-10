local QBCore = exports['qb-core']:GetCoreObject()
OutsideVehicles = {}

RegisterNetEvent('ss-garage:server:openGarage', function(garage)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local vehicles = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND garage = ?', { Player.PlayerData.citizenid, garage })

    if not vehicles[1] then
        TriggerClientEvent('QBCore:Notify', source, 'You have no vehicles in this garage', 'error')
        return
    end

    TriggerClientEvent('ss-garage:openGarage', source, vehicles, garage)
end)

RegisterNetEvent('ss-garage:server:checkPlayerForVeh', function(data)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local vehicle = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND garage = ? AND vehicle = ?', { Player.PlayerData.citizenid, data.plate, data.garage, data.model })

    if not vehicle[1] then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle', 'error')
        return
    end

    if OutsideVehicles[vehicle[1].plate] and DoesEntityExist(OutsideVehicles[vehicle[1].plate].entity) then
        TriggerClientEvent('QBCore:Notify', source, 'This vehicle is already out', 'error')
        return
    end

    TriggerClientEvent('ss-garage:takeOut', source, data)
end)

RegisterNetEvent('qb-garages:server:updateVehicleState', function(state, plate)
    exports['oxmysql']:execute('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE plate = ?', { state, 0, plate })
end)

RegisterNetEvent('ss-garage:server:swapVehicle', function(data)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local vehicle = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND garage = ?', { Player.PlayerData.citizenid, data.vehicle.plate, data.vehicle.garage })

    if not vehicle[1] then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle', 'error')
        return
    end

    if OutsideVehicles[vehicle[1].plate] and DoesEntityExist(OutsideVehicles[vehicle[1].plate].entity) then
        TriggerClientEvent('QBCore:Notify', source, 'This vehicle is already out', 'error')
        return
    end

    TriggerClientEvent('QBCore:Notify', source, 'You swapped the vehicle to '..data.garage, 'success')
    exports['oxmysql']:execute('UPDATE player_vehicles SET garage = ? WHERE plate = ?', { data.garage, data.vehicle.plate })
end)

RegisterNetEvent('ss-garage:server:transferVehicle', function(data)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local vehicle = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND garage = ?', { Player.PlayerData.citizenid, data.vehicle.plate, data.vehicle.garage })

    if not vehicle[1] then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle', 'error')
        return
    end

    if OutsideVehicles[vehicle[1].plate] and DoesEntityExist(OutsideVehicles[vehicle[1].plate].entity) then
        TriggerClientEvent('QBCore:Notify', source, 'This vehicle is already out', 'error')
        return
    end

    local target = QBCore.Functions.GetPlayer(tonumber(data.id))

    if not target then
        TriggerClientEvent('QBCore:Notify', source, 'This player is not online', 'error')
        return
    end

    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You have transferred your vehicle to '..target.PlayerData.charinfo.firstname..' '..target.PlayerData.charinfo.lastname, 'success')
    TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'You have received a vehicle from '..Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname, 'success')
    exports['oxmysql']:execute('UPDATE player_vehicles SET citizenid = ?, license = ? WHERE plate = ?', { target.PlayerData.citizenid, target.PlayerData.license, data.vehicle.plate })
end)

RegisterNetEvent('ss-garage:server:handleParking', function(plate, vehicleNetID, fuel, engine, body)
    OutsideVehicles[plate] = { netID = vehicleNetID, entity = NetworkGetEntityFromNetworkId(vehicleNetID) }
    exports['oxmysql']:execute('UPDATE player_vehicles SET fuel = ?, engine = ?, body = ? WHERE plate = ?', { fuel, engine, body, plate })
end)

QBCore.Functions.CreateCallback('qb-garages:server:canDeposit', function(source, cb, plate, type, garage, state)
    local Player = QBCore.Functions.GetPlayer(source)
    -- local isOwned = exports['oxmysql']:fetch('SELECT * FROM player_vehicles WHERE plate = ?', { tostring(plate) })
    local vehicle = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', { Player.PlayerData.citizenid, plate})
    if not vehicle[1] then cb(false) return end
    if type == 'house' and not exports['qb-houses']:hasKey(Player.PlayerData.license, Player.PlayerData.citizenid, Config.HouseGarages[garage].label) then
        cb(false)
        return
    end
    if state == 1 then
        exports['oxmysql']:execute('UPDATE player_vehicles SET state = ?, garage = ? WHERE plate = ?', { state, garage, plate })
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-garages:server:spawnvehicle', function(source, cb, plate, vehicle, coords)
    local vehType = QBCore.Shared.Vehicles[vehicle] and QBCore.Shared.Vehicles[vehicle].type or GetVehicleTypeByModel(vehicle)
    local veh = CreateVehicleServerSetter(GetHashKey(vehicle), vehType, coords.x, coords.y, coords.z, coords.w)
    local netId = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleNumberPlateText(veh, plate)
    local vehProps = {}
    local result = exports['oxmysql']:fetchSync('SELECT mods FROM player_vehicles WHERE plate = ?', { plate })
    if result and result[1] then vehProps = json.decode(result[1].mods) end
    OutsideVehicles[plate] = { netID = netId, entity = veh }
    print(json.encode(OutsideVehicles))
    cb(netId, vehProps, plate)
end)