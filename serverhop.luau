-- creds to the one dude that made this, i just made it better
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local RemoveErrorPrompts = true
local IterationSpeed = 0.25
local ExcludefullServers = true
local SaveTeleportAttempts = true
local API = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
local TeleportCount = 0

local function FetchServers(cursor)
    local url = API .. "&excludeFullGames=" .. tostring(ExcludefullServers)
    if cursor then
        url = url .. "&cursor=" .. cursor
    end

    local response = nil
    for attempt = 1, 3 do
        local success, res = pcall(function()
            return game:HttpGet(url)
        end)

        if success and type(res) == "string" and #res > 0 and string.sub(res, 1, 1) == "{" then
            response = res
            break
        else
            task.wait(1) 
        end
    end

    if not response then
        return nil
    end

    local success, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if success and decoded and decoded.data then
        decoded.gameId = game.PlaceId
        local encodeSuccess, encoded = pcall(function()
            return HttpService:JSONEncode(decoded)
        end)
        if encodeSuccess then
            writefile("Servers.JSON", encoded)
        end
        return decoded
    else
        warn("might be getting rate limited twin")
        return nil
    end
end

local function StartTeleport()
    local JSONData = nil

    if isfile("Servers.JSON") then
        local success, content = pcall(readfile, "Servers.JSON")
        if success and content then
            local decodeSuccess, decoded = pcall(function()
                return HttpService:JSONDecode(content)
            end)
            if decodeSuccess and decoded and decoded.gameId == game.PlaceId then
                JSONData = decoded
            end
        end
    end

    if not JSONData then
        JSONData = FetchServers(nil)
        if not JSONData then
            warn("failed to fetch initial servers")
            task.wait(5)
            return StartTeleport()
        end
    end

    while true do
        if not JSONData.data or #JSONData.data == 0 then
            local nextCursor = JSONData.nextPageCursor
            if not nextCursor then
                warn("no more servers found")
                if isfile("Servers.JSON") then
                    delfile("Servers.JSON")
                end
                task.wait(5)
                return StartTeleport()
            end

            JSONData = FetchServers(nextCursor)
            if not JSONData then
                warn("failed to fetch next page")
                task.wait(5)
                return StartTeleport()
            end
        else
            local JobId = JSONData.data[1].id
            table.remove(JSONData.data, 1)

            local encodeSuccess, encoded = pcall(function()
                return HttpService:JSONEncode(JSONData)
            end)
            if encodeSuccess then
                writefile("Servers.JSON", encoded)
            end

            if SaveTeleportAttempts then
                pcall(appendfile, "Attempts.txt", JobId .. "\n")
            end

            TeleportCount = TeleportCount + 1

            TeleportService:TeleportToPlaceInstance(game.PlaceId, JobId, game.Players.LocalPlayer)
            task.wait(IterationSpeed)
        end
    end
end

if RemoveErrorPrompts then 
    pcall(function()
        CoreGui:WaitForChild("RobloxGui"):WaitForChild("Modules"):WaitForChild("ErrorPrompt"):Destroy()
        CoreGui.RobloxPromptGui:Destroy()
    end)
end

StartTeleport()
