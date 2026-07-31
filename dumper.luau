if type(getgenv().cfg) ~= "table" then getgenv().cfg = {} end
local speed = 5
if type(getgenv().cfg.speed) == "number" and getgenv().cfg.speed > 0 then
    speed = getgenv().cfg.speed
end

local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local lplayer = players.LocalPlayer
local out = {}
local ops = 0
local tops = 0
local ct = "starting"
local mbps = 0
local lst = os.clock()
local lsb = 0
local cbytes = 0
local stopped = false
local lyield = os.clock()

local sg = Instance.new("ScreenGui")
sg.Name = "dumpr"
sg.ResetOnSpawn = false
sg.Parent = gethui()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 210)
frame.Position = UDim2.new(0.5, -210, 0.5, -105)
frame.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
frame.BorderSizePixel = 0
frame.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -110, 0, 28)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "lunar x dumper"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.Code
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local STOP = Instance.new("TextButton")
STOP.Size = UDim2.new(0, 80, 0, 28)
STOP.Position = UDim2.new(1, -90, 0, 8)
STOP.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
STOP.TextColor3 = Color3.new(1, 1, 1)
STOP.Font = Enum.Font.Code
STOP.TextSize = 14
STOP.Text = "stop"
STOP.Parent = frame

local scorner = Instance.new("UICorner")
scorner.CornerRadius = UDim.new(0, 6)
scorner.Parent = STOP

STOP.MouseButton1Click:Connect(function()
    stopped = true
    STOP.Text = "stopping"
end)

local target = Instance.new("TextLabel")
target.Size = UDim2.new(1, -20, 0, 24)
target.Position = UDim2.new(0, 10, 0, 42)
target.BackgroundTransparency = 1
target.Text = "current: starting"
target.TextColor3 = Color3.new(0.85, 0.85, 0.85)
target.Font = Enum.Font.Code
target.TextSize = 13
target.TextXAlignment = Enum.TextXAlignment.Left
target.TextTruncate = Enum.TextTruncate.AtEnd
target.Parent = frame

local pct = Instance.new("TextLabel")
pct.Size = UDim2.new(1, -20, 0, 22)
pct.Position = UDim2.new(0, 10, 0, 70)
pct.BackgroundTransparency = 1
pct.Text = "progress: 0.00%"
pct.TextColor3 = Color3.new(0.85, 0.85, 0.85)
pct.Font = Enum.Font.Code
pct.TextSize = 13
pct.TextXAlignment = Enum.TextXAlignment.Left
pct.Parent = frame

local sz = Instance.new("TextLabel")
sz.Size = UDim2.new(1, -20, 0, 22)
sz.Position = UDim2.new(0, 10, 0, 96)
sz.BackgroundTransparency = 1
sz.Text = "size: 0.00 MB"
sz.TextColor3 = Color3.new(0.85, 0.85, 0.85)
sz.Font = Enum.Font.Code
sz.TextSize = 13
sz.TextXAlignment = Enum.TextXAlignment.Left
sz.Parent = frame

local sp = Instance.new("TextLabel")
sp.Size = UDim2.new(1, -20, 0, 22)
sp.Position = UDim2.new(0, 10, 0, 122)
sp.BackgroundTransparency = 1
sp.Text = "speed: 0.00 MB/s"
sp.TextColor3 = Color3.new(0.85, 0.85, 0.85)
sp.Font = Enum.Font.Code
sp.TextSize = 13
sp.TextXAlignment = Enum.TextXAlignment.Left
sp.Parent = frame

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, -20, 0, 12)
bg.Position = UDim2.new(0, 10, 0, 160)
bg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
bg.BorderSizePixel = 0
bg.Parent = frame

local bgcorner = Instance.new("UICorner")
bgcorner.CornerRadius = UDim.new(0, 6)
bgcorner.Parent = bg

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.new(1, 1, 1)
bar.BorderSizePixel = 0
bar.Parent = bg

local bgcorner2 = Instance.new("UICorner")
bgcorner2.CornerRadius = UDim.new(0, 6)
bgcorner2.Parent = bar

local function add(str)
    table.insert(out, str)
    cbytes = cbytes + #str
end

local function upd()
    local bytes = cbytes + math.max(0, #out - 1)
    local mb = bytes / 1048576
    local now = os.clock()
    if now - lst >= 0.25 then
        local dt = now - lst
        if dt > 0 then
            mbps = ((bytes - lsb) / 1048576) / dt
        end
        lst = now
        lsb = bytes
    end
    target.Text = "current: " .. ct
    local p = tops > 0 and (ops / tops * 100) or 0
    pct.Text = string.format("progress: %.2f%%", p)
    sz.Text = string.format("size: %.2f MB", mb)
    sp.Text = string.format("speed: %.2f MB/s", mbps)
    bar.Size = UDim2.new(math.clamp(p / 100, 0, 1), 0, 1, 0)
end

local function beat()
    ops = ops + 1
    if ops % math.floor(100 * speed) == 0 then
        upd()
    end
    if stopped then
        error("__stop__")
    end
    if os.clock() - lyield > (0.1 / speed) then
        task.wait()
        lyield = os.clock()
    end
end

local function skip(inst)
    local s, c = pcall(function() return inst.ClassName end)
    if not s then return false end
    
    local junk = {
        Model = true, Texture = true, Sound = true,
        Accessory = true, Humanoid = true, Animation = true,
        Animator = true, ParticleEmitter = true, Trail = true,
        Beam = true, Sparkles = true, Fire = true, Smoke = true,
        Highlight = true, Weld = true, WeldConstraint = true,
        Motor6D = true, Attachment = true, Bone = true
    }
    
    if junk[c] then return true end
    
    local s2, p = pcall(function() return inst:IsA("BasePart") end)
    if s2 and p then return true end
    
    return false
end

local function countt(inst)
    tops = tops + 1
    local s, c = pcall(function() return inst:GetChildren() end)
    if not s then return end
    for _, v in ipairs(c) do
        if not skip(v) then
            countt(v)
        end
    end
end

local function counta(inst)
    tops = tops + 1
    local s, c = pcall(function() return inst:GetChildren() end)
    if s then
        for _, v in ipairs(c) do
            counta(v)
        end
    end
end

countt(rs)
counta(rs)
counta(rs)

pcall(function()
    if lplayer and lplayer.PlayerScripts then
        countt(lplayer.PlayerScripts)
        counta(lplayer.PlayerScripts)
        counta(lplayer.PlayerScripts)
    end
end)

add("-- hierarchy")
add(rs.Name .. "/")

local function tree(inst, prefix)
    beat()
    local fs, fn = pcall(function() return inst:GetFullName() end)
    ct = (fs and fn or "locked")
    
    local s, c = pcall(function() return inst:GetChildren() end)
    if not s then return end
    
    local valid = {}
    for _, v in ipairs(c) do
        if not skip(v) then
            table.insert(valid, v)
        end
    end
    
    local count = #valid
    for i, child in ipairs(valid) do
        local last = (i == count)
        local marker = last and "└── " or "├── "
        
        local ns, n = pcall(function() return child.Name end)
        local cs, cl = pcall(function() return child.ClassName end)
        
        add(prefix .. marker .. (ns and n or "locked") .. " (" .. (cs and cl or "locked") .. ")")
        
        local nprefix = prefix .. (last and "    " or "│   ")
        tree(child, nprefix)
    end
end

local function mods(inst)
    beat()
    local fs, fn = pcall(function() return inst:GetFullName() end)
    ct = (fs and fn or "locked")
    
    local ms, ismod = pcall(function() return inst:IsA("ModuleScript") or inst:IsA("LocalScript") or inst:IsA("Script") end)
    if ms and ismod then
        local ns, n = pcall(function() return inst.Name end)
        add("-- " .. string.lower(ns and n or "locked") .. " source")
        
        local s, r = pcall(function()
            local src = inst.Source
            if src and #src > 0 then return src end
            if decompile then return decompile(inst) end
            return ""
        end)
        
        if s and type(r) == "string" and r ~= "" then
            local clean = r:gsub("%-%-[^\n]*", ""):gsub("%s+", "")
            if clean ~= "returnnil;" and #clean > 0 then
                local pos = 1
                for i = 1, 4000 do -- truncation
                    local npos = string.find(r, "\n", pos, true)
                    if not npos then
                        pos = nil
                        break
                    end
                    pos = npos + 1
                end
                if pos and pos <= #r then
                    r = string.sub(r, 1, pos - 1) .. "[truncated]"
                end
                add(r)
            else
                add("error: source inaccessible")
            end
        else
            add("error: source inaccessible")
        end
        add("\n")
    end
    
    local cs, c = pcall(function() return inst:GetChildren() end)
    if cs then
        for _, child in ipairs(c) do
            mods(child)
        end
    end
end

local function vals(inst)
    beat()
    local fs, fn = pcall(function() return inst:GetFullName() end)
    ct = (fs and fn or "locked")
    
    local vs, isval = pcall(function() return inst:IsA("ValueBase") end)
    if vs and isval then
        local s, r = pcall(function() return inst.Value end)
        local v = "error"
        if s then
            if type(r) == "string" then
                v = string.format("%q", r)
            else
                v = tostring(r)
            end
        end
        
        local ps, p = pcall(function() return inst:GetFullName() end)
        local cs, c = pcall(function() return inst.ClassName end)
        
        add((ps and p or "locked") .. " (" .. (cs and c or "locked") .. ") = " .. v)
    else
        local ns, isnet = pcall(function() 
            return inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") or inst:IsA("BindableEvent") or inst:IsA("BindableFunction") 
        end)
        
        if ns and isnet then
            local ps, p = pcall(function() return inst:GetFullName() end)
            local cs, c = pcall(function() return inst.ClassName end)
            add((ps and p or "locked") .. " (" .. (cs and c or "locked") .. ")")
        end
    end
    
    local cs, c = pcall(function() return inst:GetChildren() end)
    if cs then
        for _, child in ipairs(c) do
            vals(child)
        end
    end
end

pcall(function()
    tree(rs, "")
    add("\n-- modules")
    mods(rs)
    add("-- values")
    vals(rs)

    pcall(function()
        local lps = lplayer.PlayerScripts
        if not lps then return end
        
        add("\n-- playerscripts hierarchy")
        add(lps.Name .. "/")
        tree(lps, "")
        add("\n-- playerscripts modules")
        mods(lps)
        add("\n-- playerscripts values")
        vals(lps)
    end)
end)

if stopped then
    title.Text = "stopped"
    STOP.Text = "stopped"
else
    title.Text = "done"
    STOP.Text = "stop"
end

local final = "-- dumped via lunar x\n\n" .. table.concat(out, "\n")
local pid = game.PlaceId

writefile("DUMP_"..pid..".txt", final)

upd()
task.wait(1)
sg:Destroy()
