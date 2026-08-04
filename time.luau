local secs = 0
while task.wait(1) do
        secs = secs + 1
        
        local hours = math.floor(secs / 3600)
        local minutes = math.floor((secs % 3600) / 60)
        local seconds = secs % 60
        
        local str = ""
        if hours > 0 then
            str = hours .. "h " .. minutes .. "m " .. seconds .. "s"
        elseif minutes > 0 then
            str = minutes .. "m " .. seconds .. "s"
        else
            str = seconds .. " seconds"
        end
        
        print("injected for " .. str)
end
