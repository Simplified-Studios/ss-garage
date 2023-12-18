local QBCore = exports['qb-core']:GetCoreObject()
OutsideVehicles = {}

QBCore.Functions.CreateCallback('ss-garage:server:SpawnVehicle', function(source, cb, plate, model, coords)
    local player = QBCore.Functions.GetPlayer(source)
    local vehicle = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ? AND vehicle = ?', {player.PlayerData.citizenid, plate, model})

    if not vehicle[1] then
        TriggerClientEvent('QBCore:Notify', source, 'You do not own this vehicle', 'error')
        cb(false)
        return
    end
    if vehicle[1].fakeplate ~= nil and string.len(vehicle[1].fakeplate) > 0 then
        plate = vehicle[1].fakeplate
    end
    if OutsideVehicles[plate] and DoesEntityExist(OutsideVehicles[plate].entity) then
        TriggerClientEvent('QBCore:Notify', source, 'This vehicle is already out', 'error')
        cb(false)
        return
    end

    local veh = QBCore.Functions.SpawnVehicle(source, model, coords, Config.ShouldTeleport)
    SetVehicleNumberPlateText(veh, plate)
    OutsideVehicles[plate] = { netID = NetworkGetNetworkIdFromEntity(veh), entity = veh }
    exports['oxmysql']:execute('UPDATE player_vehicles SET state = ?, depotprice = ? WHERE (plate = ? OR fakeplate = ?)', { 0, 0, plate, plate })
    cb(true, NetworkGetNetworkIdFromEntity(veh), json.decode(vehicle[1].mods), plate, vehicle[1].fuel, vehicle[1].engine, vehicle[1].body)
end)

QBCore.Functions.CreateCallback('qb-garages:server:GetPlayerVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local result = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
    
    if result[1] then
        local vehs = FormatVehicles(result)
        cb(vehs)
    else
        cb(nil)
    end
end)

RegisterNetEvent('ss-garage:server:setHouseGarages', function(data)
    Config.Garages = data
end)

QBCore.Functions.CreateCallback('qb-garages:server:canDeposit', function(source, cb, plate, type, garage, state)
    local Player = QBCore.Functions.GetPlayer(source)
    local isOwned = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND (plate = ? OR fakeplate = ?)', {Player.PlayerData.citizenid, plate})
    if not isOwned[1] then
        cb(false)
        return
    end
    if type == 'house' and not exports['qb-houses']:hasKey(Player.PlayerData.license, Player.PlayerData.citizenid, garage) then
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

QBCore.Functions.CreateCallback('ss-garage:server:GetVehicles', function(source, cb, garage, type, category)
    local Player = QBCore.Functions.GetPlayer(source)
    local result

    if type == 'depot' then
        result = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND depotprice > 0', {Player.PlayerData.citizenid})
    elseif Config.realisticGarage then
        result = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ? AND garage = ?', {Player.PlayerData.citizenid, garage})
    else
        result = exports['oxmysql']:fetchSync('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
    end

    if result[1] then
        local vehs = FormatVehicles(result)
        cb(vehs)
    else
        cb(nil)
    end
end)

RegisterNetEvent('qb-garages:server:updateVehicleStats', function(plate, fuel, engine, body)
    exports['oxmysql']:execute('UPDATE player_vehicles SET fuel = ?, engine = ?, body = ? WHERE plate = ?', { fuel, engine, body, plate })
end)

RegisterNetEvent('qb-garages:server:UpdateOutsideVehicle', function(plate, vehicleNetID)
    OutsideVehicles[plate] = {
        netID = vehicleNetID,
        entity = NetworkGetEntityFromNetworkId(vehicleNetID)
    }
end)