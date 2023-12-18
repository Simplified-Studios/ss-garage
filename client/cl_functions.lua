local QBCore = exports['qb-core']:GetCoreObject()
local garageZones = {}

function GetSpawnPoint(garage)
    local location = nil
    for k,v in pairs(Config.Garages[garage].spawnPoint) do
        local isOccupied = IsPositionOccupied( v.x, v.y, v.z, 5.0, false, true, false, false, false, 0, false )
        if not isOccupied then
            location = v
            break
        end
    end
    if not location then
        QBCore.Functions.Notify(Lang:t('error.vehicle_occupied'), 'error')
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

local function CreateBlips(setloc)
    local Garage = AddBlipForCoord(setloc.takeVehicle.x, setloc.takeVehicle.y, setloc.takeVehicle.z)
    SetBlipSprite(Garage, setloc.blipNumber)
    SetBlipDisplay(Garage, 4)
    SetBlipScale(Garage, 0.60)
    SetBlipAsShortRange(Garage, true)
    SetBlipColour(Garage, setloc.blipColor)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(setloc.blipName)
    EndTextCommandSetBlipName(Garage)
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

function IsVehicleAllowed(classList, vehicle)
    for _, class in ipairs(classList) do
        if GetVehicleClass(vehicle) == class then
            return true
        end
    end
    return false
end

function DepositVehicle(veh, data)
    local plate = QBCore.Functions.GetPlate(veh)
    QBCore.Functions.TriggerCallback('qb-garages:server:canDeposit', function(canDeposit)
        if canDeposit then
            local bodyDamage = math.ceil(GetVehicleBodyHealth(veh))
            local engineDamage = math.ceil(GetVehicleEngineHealth(veh))
            local totalFuel = exports[Config.FuelSystem]:GetFuel(veh)
            TriggerServerEvent('qb-mechanicjob:server:SaveVehicleProps', QBCore.Functions.GetVehicleProperties(veh))
            TriggerServerEvent('qb-garages:server:updateVehicleStats', plate, totalFuel, engineDamage, bodyDamage)
            CheckPlayers(veh)
            if plate then TriggerServerEvent('qb-garages:server:UpdateOutsideVehicle', plate, nil) end
            QBCore.Functions.Notify(Lang:t('success.vehicle_parked'), 'primary', 4500)
        else
            QBCore.Functions.Notify(Lang:t('error.not_owned'), 'error', 3500)
        end
    end, plate, data.type, data.indexgarage, 1)
end

function CreateZone(index, garage, zoneType)
    local zone = CircleZone:Create(garage.takeVehicle, 10.0, {
        name = zoneType .. '_' .. index,
        debugPoly = false,
        data = {
            indexgarage = index,
            type = garage.type,
            category = garage.category
        }
    })
    return zone
end

function CreateBlipsZones()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerGang = PlayerData.gang
    PlayerJob = PlayerData.job

    for index, garage in pairs(Config.Garages) do
        local zone
        if garage.showBlip then
            CreateBlips(garage)
        end
        if garage.type == 'job' and (PlayerJob.name == garage.job or PlayerJob.type == garage.jobType) then
            zone = CreateZone(index, garage, 'job')
        elseif garage.type == 'gang' and PlayerGang.name == garage.job then
            zone = CreateZone(index, garage, 'gang')
        elseif garage.type == 'depot' then
            zone = CreateZone(index, garage, 'depot')
        elseif garage.type == 'public' then
            zone = CreateZone(index, garage, 'public')
        end

        if zone then
            garageZones[#garageZones + 1] = zone
        end
    end

    local comboZone = ComboZone:Create(garageZones, { name = 'garageCombo', debugPoly = false })

    comboZone:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            listenForKey = true
            currentZone = zone
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
                            TriggerEvent('ss-garage:client:openGarage')
                        end
                    end
                end
            end)

            local displayText = Lang:t('info.car_e')
            if zone.data.vehicle == 'sea' then
                displayText = Lang:t('info.sea_e')
            elseif zone.data.vehicle == 'air' then
                displayText = Lang:t('info.air_e')
            elseif zone.data.vehicle == 'rig' then
                displayText = Lang:t('info.rig_e')
            elseif zone.data.type == 'depot' then
                displayText = Lang:t('info.depot_e')
            end
            exports['qb-core']:DrawText(displayText, 'left')
        else
            listenForKey = false
            currentZone = nil
            exports['qb-core']:HideText()
        end
    end)
end

local houseGarageZones = {}
local listenForKeyHouse = false
local houseComboZones = nil

function CreateHouseZone(index, garage, zoneType)
    local houseZone = CircleZone:Create(garage.takeVehicle, 5.0, {
        name = zoneType .. '_' .. index,
        debugPoly = true,
        data = {
            indexgarage = index,
            type = zoneType,
            label = garage.label
        }
    })

    if houseZone then
        houseGarageZones[#houseGarageZones + 1] = houseZone

        if not houseComboZones then
            houseComboZones = ComboZone:Create(houseGarageZones, { name = 'houseComboZones', debugPoly = true })
        else
            houseComboZones:AddZone(houseZone)
        end
    end

    houseComboZones:onPlayerInOut(function(isPointInside, _, zone)
        if isPointInside then
            listenForKeyHouse = true
            currentZone = zone
            CreateThread(function()
                while listenForKeyHouse do
                    Wait(0)
                    if IsControlJustReleased(0, 38) then
                        if GetVehiclePedIsUsing(PlayerPedId()) ~= 0 then
                            local currentVehicle = GetVehiclePedIsUsing(PlayerPedId())
                            DepositVehicle(currentVehicle, zone.data)
                        else
                            TriggerEvent('ss-garage:client:openGarage')
                        end
                    end
                end
            end)
            exports['qb-core']:DrawText(Lang:t('info.house_garage'), 'left')
        else
            listenForKeyHouse = false
            currentZone = nil
            exports['qb-core']:HideText()
        end
    end)
end

local function ZoneExists(zoneName)
    for _, zone in ipairs(houseGarageZones) do
        if zone.name == zoneName then
            return true
        end
    end
    return false
end

local function RemoveHouseZone(zoneName)
    local removedZone = houseComboZones:RemoveZone(zoneName)
    if removedZone then
        removedZone:destroy()
    end
    for index, zone in ipairs(houseGarageZones) do
        if zone.name == zoneName then
            table.remove(houseGarageZones, index)
            break
        end
    end
end

RegisterNetEvent('qb-garages:client:setHouseGarage', function(house, hasKey) -- event sent periodically from housing
    if not house then return end
    local formattedHouseName = string.lower(house)
    local zoneName = 'house_' .. formattedHouseName
    if Config.Garages[formattedHouseName] then
        if hasKey and not ZoneExists(zoneName) then
            CreateHouseZone(formattedHouseName, Config.Garages[formattedHouseName], 'house')
        elseif not hasKey and ZoneExists(zoneName) then
            RemoveHouseZone(zoneName)
        end
    end
    TriggerServerEvent('ss-garage:server:setHouseGarages', Config.Garages)
end)

RegisterNetEvent('qb-garages:client:houseGarageConfig', function(houseGarages)
    for _, garageConfig in pairs(houseGarages) do
        local formattedHouseName = _
        if garageConfig.takeVehicle and garageConfig.takeVehicle.x and garageConfig.takeVehicle.y and garageConfig.takeVehicle.z and garageConfig.takeVehicle.w then
            Config.Garages[formattedHouseName] = {
                takeVehicle = vector3(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z),
                spawnPoint = {
                    vector4(garageConfig.takeVehicle.x, garageConfig.takeVehicle.y, garageConfig.takeVehicle.z, garageConfig.takeVehicle.w)
                },
                label = garageConfig.label,
                type = 'house',
            }
        end
    end
    TriggerServerEvent('ss-garage:server:setHouseGarages', Config.Garages)
end)

RegisterNetEvent('qb-garages:client:addHouseGarage', function(house, garageInfo) -- event from housing on garage creation
    local formattedHouseName = string.lower(house)
    print('3', formattedHouseName)
    Config.Garages[formattedHouseName] = {
        takeVehicle = vector3(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z),
        spawnPoint = {
            vector4(garageInfo.takeVehicle.x, garageInfo.takeVehicle.y, garageInfo.takeVehicle.z, garageInfo.takeVehicle.w)
        },
        label = garageInfo.label,
        type = 'house',
    }
    TriggerServerEvent('ss-garage:server:setHouseGarages', Config.Garages)
end)

-- Handlers

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    CreateBlipsZones()
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateBlipsZones()
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerGang = gang
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
end)