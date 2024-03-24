OutsideVehicles = {}

local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    PerformHttpRequest('https://api.github.com/repos/Simplified-Studios/ss-garage/releases/latest', function(code, text, headers)
        if code == 200 then
            local data = json.decode(text)
            local latestVersion = data.tag_name:gsub("v", "")

            if currentVersion ~= latestVersion then
                print('A new version of SS-Garage is available! (v' .. latestVersion .. ')')
            else
                print('You are running the latest version of SS-Garage.')
            end
        else
            print('Failed to check for updates.')
        end
    end, 'GET', '', { ['Content-Type'] = 'application/json' })
end)