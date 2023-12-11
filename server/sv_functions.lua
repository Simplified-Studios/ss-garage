local QBCore = exports['qb-core']:GetCoreObject()

local vehicleTypes = { -- https://docs.fivem.net/natives/?_0xA273060E
    motorcycles = 'bike',
    boats = 'boat',
    helicopters = 'heli',
    planes = 'plane',
    submarines = 'submarine',
    trailer = 'trailer',
    train = 'train'
}

function GetVehicleTypeByModel(model)
    local vehicleData = QBCore.Shared.Vehicles[model]
    if not vehicleData then return 'automobile' end
    local category = vehicleData.category
    local vehicleType = vehicleTypes[category]
    return vehicleType or 'automobile'
end