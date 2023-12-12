local QBCore = exports['qb-core']:GetCoreObject()

function GetSpawnPoint(garage)
    local location = nil
    if #Config.Garages[garage].spawnPoint > 1 then
        for i = 1, #Config.Garages[garage].spawnPoint do
            local chosenSpawnPoint = Config.Garages[garage].spawnPoint[i]
            local isOccupied = IsPositionOccupied( chosenSpawnPoint.x, chosenSpawnPoint.y, chosenSpawnPoint.z, 5.0, false, true, false, false, false, 0, false )
            if not isOccupied then
                location = chosenSpawnPoint
                break
            end
        end
    elseif #Config.Garages[garage].spawnPoint == 1 then
        location = Config.Garages[garage].spawnPoint[1]
    end
    if not location then
        QBCore.Functions.Notify("There are no available spawn points", "error")
    end
    return location
end

function doCarDamage(currentVehicle, stats, props)
    local engine = stats.engine + 0.0
    local body = stats.body + 0.0
    SetVehicleEngineHealth(currentVehicle, engine)
    SetVehicleBodyHealth(currentVehicle, body)
    if not next(props) then return end
    if props.doorStatus then
        for k, v in pairs(props.doorStatus) do
            if v then SetVehicleDoorBroken(currentVehicle, tonumber(k), true) end
        end
    end
    if props.tireBurstState then
        for k, v in pairs(props.tireBurstState) do
            if v then SetVehicleTyreBurst(currentVehicle, tonumber(k), true) end
        end
    end
    if props.windowStatus then
        for k, v in pairs(props.windowStatus) do
            if not v then SmashVehicleWindow(currentVehicle, tonumber(k)) end
        end
    end
end

function IsVehicleAllowed(classList, vehicle)
    if not Config.ClassSystem then return true end
    for _, class in ipairs(classList) do
        if GetVehicleClass(vehicle) == class then
            return true
        end
    end
    return false
end

function CheckPlayers(vehicle)
    for i = -1, 5, 1 do
        local seat = GetPedInVehicleSeat(vehicle, i)
        if seat then
            TaskLeaveVehicle(seat, vehicle, 0)
        end
    end
    Wait(1500)
    QBCore.Functions.DeleteVehicle(vehicle)
end