<h1>About Us</h1>
We're a team with experience in FiveM and UI development, we've played FiveM for thousands of hours, and have a clear understanding of the players needs. That caused us to start Simplified Studios.

[Simplified Studios Discord](https://discord.gg/7YHRdV9San) is where you can find all of our updates, new scripts and maybe some sneak peaks if you're lucky!

[Simplified Studios Tebex](https://simplified-studios.tebex.io/) is where you can buy our paid scripts!

# Installation

This script is really just plug n play, unless you want to use the Renewed Phone, then you need to follow the instructions below.
If you want pictures on the garages, you need to take pictures rename them as they are called in the config and put them into the html/img folder.

# Use of Renewed Phone

if you're using the default qb-phone you dont need to do anything, just plug n play.
if you're using Renewed Phone, you need to navigate to server/garage.lua and replace the current Callback "qb-phone:server:GetGarageVehicles" with this:

```lua
QBCore.Functions.CreateCallback('qb-phone:server:GetGarageVehicles', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Vehicles = {}
    local vehdata
    local result = exports.oxmysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
    local garages = exports['ss-garage']:GetGarages()
    if result[1] then
        for _, v in pairs(result) do
            local VehicleData = QBCore.Shared.Vehicles[v.vehicle]
            local VehicleGarage = "None"
            local enginePercent = round(v.engine / 10, 0)
            local bodyPercent = round(v.body / 10, 0)
            if v.garage then
                if garages[v.garage] then
                    VehicleGarage = garages[v.garage]["label"]
                else
                    VehicleGarage = v.garage
                end
            end

            local VehicleState = "In"
            if v.state == 0 then
                VehicleState = "Out"
            elseif v.state == 2 then
                VehicleState = "Impounded"
            end

            if VehicleData["brand"] then
                vehdata = {
                    fullname = VehicleData["brand"] .. " " .. VehicleData["name"],
                    brand = VehicleData["brand"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = v.fuel,
                    engine = enginePercent,
                    body = bodyPercent,
                    paymentsleft = v.paymentsleft
                }
            else
                vehdata = {
                    fullname = VehicleData["name"],
                    brand = VehicleData["name"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = v.fuel,
                    engine = enginePercent,
                    body = bodyPercent,
                    paymentsleft = v.paymentsleft
                }
            end
            Vehicles[#Vehicles+1] = vehdata
        end
        cb(Vehicles)
    else
        cb(nil)
    end
end)
```
