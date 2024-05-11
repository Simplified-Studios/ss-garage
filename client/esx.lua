if Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()

    RegisterNetEvent('ss-garage:client:SpawnVehicle', function(data)
        local coords = GetFreeSpot()

        if coords == nil then return ESX.ShowNotification(Locales[Config.Language]['noparkingspace']) end

        ESX.TriggerServerCallback('ss-garage:esx-spawnVehicle', function(netid, properties, plate)
            if netid then
                local veh = NetToVeh(netid)
                SetVehicleProperties(veh, properties)
                local stats = { engine = data.engine, body = data.body, fuel = data.fuel }
                doCarDamage(veh, stats, properties)
                TriggerServerEvent('ss-garage:esx-setState', plate, 0)
            end
        end, data.plate, data.vehicle, coords)
    end)

    RegisterNetEvent('ss-garage:client:ParkVehicle', function(vehicle, plate, vehProps, garage)
        ESX.TriggerServerCallback('ss-garage:esx-parkVehicle', function(success)
            if success then
                ESX.Game.DeleteVehicle(vehicle)
                ESX.ShowNotification(Locales[Config.Language]['vparked'])
            else
                ESX.ShowNotification(Locales[Config.Language]['notowned'])
            end
        end, plate, vehProps, garage)
    end)

    RegisterNetEvent('ss-garage:client:PayForImpound', function(data)
        ESX.TriggerServerCallback('ss-garage:esx-payForImpound', function(success)
            if success then
                TriggerEvent('ss-garage:client:SpawnVehicle', data.vehicle)
                ESX.ShowNotification(Locales[Config.Language]['impoundpaid'])
            else
                ESX.ShowNotification(Locales[Config.Language]['unotenough'])
            end
        end, data)
    end)

    function ESX:OpenGarage(id)
        local garage = Config.Garages[id]
        ESX.TriggerServerCallback('ss-garage:esx-getvehicles', function(vehicles)
            if vehicles then
                local sortedVehicles = {}
                for _,vehicleData in pairs(vehicles) do
                    local data = json.decode(vehicleData.vehicle)
                    local modelName = GetDisplayNameFromVehicleModel(data.model) or data.model
                    table.insert(sortedVehicles, {
                        plate = vehicleData.plate,
                        label = GetLabelText(modelName),
                        state = vehicleData.stored,
                        isImpounded = vehicleData.stored == 2,
                        impoundPrice = Config.Impound.DefaultImpoundPrice,
                        garage = vehicleData.parking,
                        vehicle = modelName,
                        fuel = Round(data.fuelLevel or 100, 1),
                        engine = Round(data.engineHealth, 1),
                        body = Round(data.bodyHealth, 1),
                    })
                end
                SendNUIMessage({
                    action = "open",
                    vehicles = sortedVehicles,
                    garages = Config.Garages,
                    garage = id,
                    locale = Locales[Config.Language]["UI"],
                })
                SetNuiFocus(true, true)
            else
                print('No vehicles found')
            end
        end, id, garage.type, garage.category)
    end
end