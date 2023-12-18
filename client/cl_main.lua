local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ss-garage:client:openGarage', function()
    QBCore.Functions.TriggerCallback('ss-garage:server:GetVehicles', function(vehicles)
        if not vehicles then QBCore.Functions.Notify('You have no vehicles in this garage', 'error') return end
        SendNUIMessage({
            type = "open",
            vehicles = vehicles,
            garages = Config.Garages,
            garageindex = currentZone.data.indexgarage,
        })
        SetNuiFocus(true, true)
    end, currentZone.data.indexgarage, currentZone.data.type, currentZone.data.category)
end)

RegisterNUICallback('takeOut', function(data, cb)
    local dataveh = data.vehicle
    local location = GetSpawnPoint(currentZone.data.indexgarage)
    if not location then return end
    QBCore.Functions.TriggerCallback('ss-garage:server:SpawnVehicle', function(success, netid, properties, plate, fuel, engine, body)
        while not NetworkDoesNetworkIdExist(netid) do Wait(10) end
        local veh = NetworkGetEntityFromNetworkId(netid)
        QBCore.Functions.SetVehicleProperties(veh, properties)
        exports[Config.FuelSystem]:SetFuel(veh, fuel)
        doCarDamage(veh, {engine = engine, body = body}, properties)
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
    end, dataveh.plate, dataveh.spawn, location)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('transfer', function(data, cb)
    TriggerServerEvent('ss-garage:server:TransferVehicle', data)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('swap', function(data, cb)
    TriggerServerEvent('ss-garage:server:SwapVehicle', data)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)