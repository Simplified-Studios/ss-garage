local QBCore = exports['qb-core']:GetCoreObject()

function FormatVehicles(result)
    local Vehicles = {}
    for _, v in pairs(result) do
        local VehicleData = QBCore.Shared.Vehicles[v.vehicle]

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
            spawn = VehicleData['model'],
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