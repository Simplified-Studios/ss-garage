local QBCore = exports['qb-core']:GetCoreObject()

function FormatVehicles(result)
    local Vehicles = {}
    for _, v in pairs(result) do
        local VehicleGarage = Lang:t('error.no_garage')
        if v.garage ~= nil then
            if Config.Garages[v.garage] ~= nil then
                VehicleGarage = Config.Garages[v.garage].label
            else
                VehicleGarage = Lang:t('info.house')
            end
        end

        local stateTranslation
        if v.state == 0 then
            stateTranslation = Lang:t('status.out')
        elseif v.state == 1 then
            stateTranslation = Lang:t('status.garaged')
        elseif v.state == 2 then
            stateTranslation = Lang:t('status.impound')
        end

        Vehicles[#Vehicles + 1] = {
            fullname = QBCore.Shared.Vehicles[v.vehicle]['brand'].. ' '..QBCore.Shared.Vehicles[v.vehicle]['name'] or v.vehicle,
            spawn = v.vehicle,
            plate = v.plate,
            garage = VehicleGarage,
            garageindex = v.garage,
            state = stateTranslation,
            fuel = v.fuel,
            engine = v.engine,
            body = v.body
        }
    end
    return Vehicles
end

exports('GetGarages', function()
    return Config.Garages
end)