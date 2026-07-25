--getgenv().cfg.speed = 5
--loadstring(game:HttpGet("https://raw.githubusercontent.com/codexvsberserkerxylo/scripts/refs/heads/main/dumper.luau"))()

getgenv().cfg = getgenv().cfg or {}
local speedMult = getgenv().cfg.speed or 1
if type(speedMult) ~= "number" or speedMult <= 0 then speedMult = 1 end

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
local currentBytes = 0
local stopped = false
local lastYield = os.clock()

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

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 80, 0, 28)
stopBtn.Position = UDim2.new(1, -90, 0, 8)
stopBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
stopBtn.TextColor3 = Color3.new(1, 1, 1)
stopBtn.Font = Enum.Font.Code
stopBtn.TextSize = 14
stopBtn.Text = "Stop"
stopBtn.Parent = frame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 6)
stopCorner.Parent = stopBtn

stopBtn.MouseButton1Click:Connect(function()
    stopped = true
    stopBtn.Text = "stopping"
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

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -20, 0, 12)
barBg.Position = UDim2.new(0, 10, 0, 160)
barBg.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
barBg.BorderSizePixel = 0
barBg.Parent = frame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 6)
barCorner.Parent = barBg

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.new(1, 1, 1)
bar.BorderSizePixel = 0
bar.Parent = barBg

local barCorner2 = Instance.new("UICorner")
barCorner2.CornerRadius = UDim.new(0, 6)
barCorner2.Parent = bar

local function addOut(str)
    table.insert(out, str)
    currentBytes = currentBytes + #str
end

local function upd()
    local bytes = currentBytes + math.max(0, #out - 1)
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
    if ops % math.floor(100 * speedMult) == 0 then
        upd()
    end
    if stopped then
        error("__stop__")
    end
    if os.clock() - lastYield > (0.1 / speedMult) then
        task.wait()
        lastYield = os.clock()
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

local function countTree(inst)
    tops = tops + 1
    local s, c = pcall(function() return inst:GetChildren() end)
    if not s then return end
    for _, v in ipairs(c) do
        if not skip(v) then
            countTree(v)
        end
    end
end

local function countAll(inst)
    tops = tops + 1
    local s, c = pcall(function() return inst:GetChildren() end)
    if s then
        for _, v in ipairs(c) do
            countAll(v)
        end
    end
end

countTree(rs)
countAll(rs)
countAll(rs)

pcall(function()
    if lplayer and lplayer.PlayerScripts then
        countTree(lplayer.PlayerScripts)
        countAll(lplayer.PlayerScripts)
        countAll(lplayer.PlayerScripts)
    end
end)

addOut("-- hierarchy")
addOut(rs.Name .. "/")

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
        
        addOut(prefix .. marker .. (ns and n or "locked") .. " (" .. (cs and cl or "locked") .. ")")
        
        local nprefix = prefix .. (last and "    " or "│   ")
        tree(child, nprefix)
    end
end

local function mods(inst)
    beat()
    local fs, fn = pcall(function() return inst:GetFullName() end)
    ct = (fs and fn or "locked")
    
    local ms, ismod = pcall(function() return inst:IsA("ModuleScript") end)
    if ms and ismod then
        local ns, n = pcall(function() return inst.Name end)
        addOut("-- " .. string.lower(ns and n or "locked") .. " source")
        
        local s, r = pcall(function()
            if decompile then
                return decompile(inst)
            end
            return inst.Source
        end)
        
        if s and type(r) == "string" and r ~= "" then
            addOut(r)
        else
            addOut("error: source inaccessible")
        end
        addOut("\n")
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
        
        addOut((ps and p or "locked") .. " (" .. (cs and c or "locked") .. ") = " .. v)
    else
        local ns, isnet = pcall(function() 
            return inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") or inst:IsA("BindableEvent") or inst:IsA("BindableFunction") 
        end)
        
        if ns and isnet then
            local ps, p = pcall(function() return inst:GetFullName() end)
            local cs, c = pcall(function() return inst.ClassName end)
            addOut((ps and p or "locked") .. " (" .. (cs and c or "locked") .. ")")
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
    addOut("\n-- modules")
    mods(rs)
    addOut("-- values")
    vals(rs)

    pcall(function()
        local lps = lplayer.PlayerScripts
        if not lps then return end
        
        addOut("\n-- playerscripts hierarchy")
        addOut(lps.Name .. "/")
        tree(lps, "")
        addOut("\n-- playerscripts modules")
        mods(lps)
        addOut("\n-- playerscripts values")
        vals(lps)
    end)
end)

if stopped then
    title.Text = "stopped"
    stopBtn.Text = "stopped"
else
    title.Text = "done"
    stopBtn.Text = "stop"
end

local final = table.concat(out, "\n")
local pid = game.PlaceId

writefile("DUMP_"..pid.."_lx.txt", final)

upd()
task.wait(1)
sg:Destroy()
