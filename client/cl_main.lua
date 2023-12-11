local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ss-garage:openGarage', function(data, garage)
    local vehicles = {}
    for k,v in pairs(data) do
        vehicles[#vehicles+1] = {
            plate = v.plate,
            model = v.vehicle,
            garage = v.garage,
            state = v.state,
            name = QBCore.Shared.Vehicles[v.vehicle].name or v.vehicle,
            fuel = v.fuel,
            engine = v.engine / 10,
            body = v.body / 10,
            impounded = v.depotprice > 0 and true or false,
            fakeplate = v.fakeplate,
        }
    end
    SendNUIMessage({
        type = "open",
        vehicles = vehicles,
        garages = Config.Garages,
        garageindex = garage,
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('ss-garage:takeOut', function(data)
    local location = GetSpawnPoint(data.garage)
    if not location then return end
    QBCore.Functions.TriggerCallback('qb-garages:server:spawnvehicle', function(netId, properties, vehPlate)
        while not NetworkDoesNetworkIdExist(netId) do Wait(10) end
        local veh = NetworkGetEntityFromNetworkId(netId)
        QBCore.Functions.SetVehicleProperties(veh, properties)
        exports['LegacyFuel']:SetFuel(veh, data.fuel)
        TriggerServerEvent('qb-garages:server:updateVehicleState', 0, vehPlate)
        TriggerEvent('vehiclekeys:client:SetOwner', vehPlate)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        doCarDamage(veh, {engine = data.engine * 10, fuel = data.fuel, body = data.body * 10}, properties)
        SetVehicleEngineOn(veh, true, true, false)
    end, data.plate, data.model, location, data.fakeplate)
end)

RegisterNUICallback('takeOut', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('ss-garage:server:checkPlayerForVeh', data.vehicle)
    cb('ok')
end)

RegisterNUICallback('transfer', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('ss-garage:server:transferVehicle', data)
    cb('ok')
end)

RegisterNUICallback('swap', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('ss-garage:server:swapVehicle', data)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

local garageZones = {}
local blips = {}
CreateThread(function()
    for index, garage in pairs(Config.Garages) do

        if garage.showBlip then
            blips[index] = AddBlipForCoord(garage.takeVehicle)
            SetBlipSprite(blips[index], garage.blipNumber)
            SetBlipDisplay(blips[index], 4)
            SetBlipScale(blips[index], 0.7)
            SetBlipColour(blips[index], garage.blipColor)
            SetBlipAsShortRange(blips[index], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(garage.blipName)
            EndTextCommandSetBlipName(blips[index])
        end

        local zone = CircleZone:Create(garage.takeVehicle, 10.0, {
            name =  'garage_' .. index,
            debugPoly = false,
            data = {
                indexgarage = index,
                type = garage.type,
                category = garage.category
            }
        })

        if zone then
            garageZones[#garageZones + 1] = zone
        end
    end

    local comboZone = ComboZone:Create(garageZones, { name = 'garageCombo', debugPoly = false })

    comboZone:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            listenForKey = true
            CreateThread(function()
                while listenForKey do
                    Wait(0)
                    if IsControlJustReleased(0, 38) then
                        if GetVehiclePedIsUsing(PlayerPedId()) ~= 0 then
                            if zone.data.type == 'depot' then return end
                            local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
                            if not IsVehicleAllowed(zone.data.category, currentVehicle) then
                                QBCore.Functions.Notify(Lang:t('error.not_correct_type'), 'error', 3500)
                                return
                            end
                            DepositVehicle(currentVehicle, zone.data)
                        else
                            TriggerServerEvent('ss-garage:server:openGarage', zone.data.indexgarage)
                        end
                    end
                end
            end)
            exports['qb-core']:DrawText("E - Garage", 'left')
        else
            listenForKey = false
            exports['qb-core']:HideText()
        end
    end)
end)

function DepositVehicle(veh, data)
    local plate = QBCore.Functions.GetPlate(veh)
    QBCore.Functions.TriggerCallback('qb-garages:server:canDeposit', function(canDeposit)
        if canDeposit then
            local bodyDamage = math.ceil(GetVehicleBodyHealth(veh))
            local engineDamage = math.ceil(GetVehicleEngineHealth(veh))
            local totalFuel = exports['LegacyFuel']:GetFuel(veh)
            TriggerServerEvent('qb-mechanicjob:server:SaveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            CheckPlayers(veh)
            TriggerServerEvent('ss-garage:server:handleParking', plate, nil, totalFuel, engineDamage, bodyDamage)
            QBCore.Functions.Notify(Lang:t('success.vehicle_parked'), 'primary', 4500)
        else
            QBCore.Functions.Notify(Lang:t('error.not_owned'), 'error', 3500)
        end
    end, plate, data.type, data.indexgarage, 1)
end
