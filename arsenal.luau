--[[
    Lunar X
    Copyright (c) 2026 nick (.weound)

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]

-- "i need to make this open source or else it would lag so fuck you obfuscators" - nick 2026

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"))()
local flags = library.flags
library.directory = "LunarX-ar"

function library:config_list_update()
    if not library.config_holder then return end
    local list = {}
    local dir = library.directory .. "/configs/"
    if isfolder(dir) then
        for _, f in next, listfiles(dir) do
            local name = string.match(f, "([^/\\]+)%.cfg$")
            if name then table.insert(list, name) end
        end
    end
    library.config_holder:refresh_options(list)
end

local plrs = game:GetService("Players")
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local ws = game:GetService("Workspace")
local light = game:GetService("Lighting")
local rs = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local s_url = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/codexvsberserkerxylo/scripts/refs/heads/main/arsenal.luau"))()'

local lp = plrs.LocalPlayer
local cam = ws.CurrentCamera
local mouse = lp:GetMouse()

local function getChar() return lp.Character end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function hex(s) return Color3.fromHex(s) end

local defaultFOV = 70
pcall(function() defaultFOV = lp.Settings.FOV.Value end)
local defaultCol = rgb(100, 100, 255)

local function is_spawned(plr)
    local c = plr.Character
    if not c then return false end
    local ws_char = ws:FindFirstChild(c.Name)
    return ws_char ~= nil and ws_char:FindFirstChild("Spawned") ~= nil
end

local function wall_check(target_char, target_part)
    if not flags["wall_check"] then return true end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {getChar(), target_char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local origin = cam.CFrame.Position
    local dir = (target_part.Position - origin)
    local hit = ws:Raycast(origin, dir, rp)
    if hit and hit.Instance then
        if hit.Instance.Transparency == 1 then return true end
        if hit.Instance:IsDescendantOf(target_char) then return true end
        return false
    end
    return true
end

local function esp_wall_check(target_char, target_part)
    if not flags["esp_wall_check"] then return true end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {getChar(), target_char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local origin = cam.CFrame.Position
    local dir = (target_part.Position - origin)
    local hit = ws:Raycast(origin, dir, rp)
    if hit and hit.Instance then
        if hit.Instance.Transparency == 1 then return true end
        if hit.Instance:IsDescendantOf(target_char) then return true end
        return false
    end
    return true
end

local conns = {}
local function connect(sig, cb) 
    local c = sig:Connect(cb)
    table.insert(conns, c)
    return c 
end

local function disconnect_all()
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    conns = {}
end

local function newDraw(t, props)
    local d = Drawing.new(t)
    for k, v in pairs(props) do d[k] = v end
    return d
end

local ws_hooked = false
local ws_enabled = false
local jp_enabled = false

local function setup_ws_hook()
    if ws_hooked then return end
    ws_hooked = true
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldindex = gmt.__index
    gmt.__index = newcclosure(function(self, b)
        if b == "WalkSpeed" and ws_enabled and self:IsA("Humanoid") then return 16 end
        if b == "JumpPower" and jp_enabled and self:IsA("Humanoid") then return 50 end
        return oldindex(self, b)
    end)
end

local function apply_walkspeed(state, speed)
    setup_ws_hook()
    ws_enabled = state
    local hum = getHum()
    if hum then hum.WalkSpeed = state and (speed or 50) or 16 end
end

local function apply_jumppower(state, power)
    setup_ws_hook()
    jp_enabled = state
    local hum = getHum()
    if hum then hum.JumpPower = state and (power or 50) or 50 end
end

connect(run.Heartbeat, function()
    if ws_enabled then
        local hum = getHum()
        if hum and hum.WalkSpeed ~= (flags["walkspeed"] or 50) then hum.WalkSpeed = flags["walkspeed"] or 50 end
    end
    if jp_enabled then
        local hum = getHum()
        if hum and hum.JumpPower ~= (flags["jump_power"] or 50) then hum.JumpPower = flags["jump_power"] or 50 end
    end
end)

local state = {
    skinColors = { arm = rgb(50, 50, 50), gun = rgb(50, 50, 50) },
    skinMats = { arm = "Plastic", gun = "Plastic" },
    armSkinOn = false, gunSkinOn = false, rainbowOn = false, rainbowHue = 0,
    triggerAlive = true, triggerCooldown = 0,
    aim_target_part = nil, 
    aim_target_player = nil,
    lastClickTime = 0,
    lookingAtPlayer = nil,
    lookingAtPart = nil,
    colors = {
        box = rgb(100, 255, 255), boxFill = rgb(100, 255, 255), boxFillTr = 0.5,
        tracer = rgb(100, 100, 255), tracerThick = 1, snapLine = rgb(255, 100, 100), snapThick = 1,
        skel = rgb(255, 100, 255), xhair = rgb(255, 255, 255), fov = rgb(100, 100, 255), fovTr = 0,
        hlEnemy = rgb(255, 50, 50), chams = rgb(170, 85, 235), name = rgb(255, 255, 255),
        dist = rgb(180, 180, 180), weapon = rgb(100, 255, 100), placement = rgb(255, 255, 100)
    }
}

local keybinds = { aim = false, trigger = false, fly = false, blink = false, killall = false }

local lightOrig = {
    Ambient = light.Ambient, Brightness = light.Brightness,
    FogEnd = light.FogEnd, FogStart = light.FogStart
}
local desiredBrightness = light.Brightness
local desiredClockTime = light.ClockTime

local skel_pairs = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"}
}

local xhairLines = {
    top = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    bottom = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    left = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    right = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.xhair}),
    dot = newDraw("Circle", {Radius = 2, Filled = true, Visible = false, Color = state.colors.xhair})
}

local fovCircle = newDraw("Circle", {
    NumSides = 60, Thickness = 1, Filled = false,
    Visible = false, Color = state.colors.fov, Radius = 150
})

local espObjects = {}

local function buildESP(pl)
    if pl == lp then return end
    local corners = {}
    for i = 1, 8 do corners[i] = newDraw("Line", {Thickness = 2, Visible = false, Color = state.colors.box}) end
    local skeleton = {}
    for i = 1, #skel_pairs do skeleton[i] = newDraw("Line", {Thickness = 1, Visible = false, Color = state.colors.skel}) end
    
    espObjects[pl] = {
        box = newDraw("Square", {Thickness = 1, Filled = false, Visible = false, Color = state.colors.box}),
        boxFill = newDraw("Square", {Filled = true, Visible = false, Color = state.colors.boxFill, Transparency = state.colors.boxFillTr}),
        corners = corners,
        skeleton = skeleton,
        nameText = newDraw("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = state.colors.name, Font = 2}),
        distText = newDraw("Text", {Size = 11, Center = true, Outline = true, Visible = false, Color = state.colors.dist, Font = 2}),
        weaponText = newDraw("Text", {Size = 12, Center = true, Outline = true, Visible = false, Color = state.colors.weapon, Font = 2}),
        placementText = newDraw("Text", {Size = 12, Center = true, Outline = true, Visible = false, Color = state.colors.placement, Font = 2}),
        hpBG = newDraw("Square", {Filled = true, Visible = false, Color = rgb(0, 0, 0)}),
        hpBar = newDraw("Square", {Filled = true, Visible = false, Color = rgb(0, 255, 0)}),
        hpText = newDraw("Text", {Size = 10, Center = true, Outline = true, Visible = false, Color = rgb(255, 255, 255), Font = 2}),
        tracer = newDraw("Line", {Thickness = 1, Visible = false, Color = state.colors.tracer}),
        snapLine = newDraw("Line", {Thickness = 1, Visible = false, Color = state.colors.snapLine})
    }
end

local function destroyESP(pl)
    local d = espObjects[pl]
    if not d then return end
    for _, v in pairs(d.corners) do pcall(function() v:Remove() end) end
    for _, v in pairs(d.skeleton) do pcall(function() v:Remove() end) end
    for k, v in pairs(d) do
        if k ~= "corners" and k ~= "skeleton" then pcall(function() v:Remove() end) end
    end
    espObjects[pl] = nil
end

for _, pl in ipairs(plrs:GetPlayers()) do buildESP(pl) end
connect(plrs.PlayerAdded, buildESP)
connect(plrs.PlayerRemoving, destroyESP)

local pickupESPObjects = {}
local pickupESPEnabled = { ammo = false, hp = false }

local function removePickupDraw(d) 
    pcall(function() d.text:Remove(); d.box:Remove() end) 
end

local function cleanupPickupESP()
    for obj, d in pairs(pickupESPObjects) do
        if not obj or not obj.Parent then removePickupDraw(d); pickupESPObjects[obj] = nil end
    end
end

local function buildPickupESPFor(obj)
    if pickupESPObjects[obj] then return end
    local isAmmo = obj.Name == "DeadAmmo"
    local col = state.colors.box
    pickupESPObjects[obj] = {
        text = newDraw("Text", {Size = 12, Center = true, Outline = true, Visible = false, Color = col, Font = 2, Text = isAmmo and "ammo box" or "hp jug"}),
        box = newDraw("Square", {Filled = true, Visible = false, Color = col, Transparency = 0.5, Thickness = 0})
    }
end

local function refreshPickupESP()
    cleanupPickupESP()
    local debris = ws:FindFirstChild("Debris")
    if not debris then return end
    for _, v in ipairs(debris:GetChildren()) do
        local isAmmo = v.Name == "DeadAmmo" and pickupESPEnabled.ammo
        local isHP = v.Name == "DeadHP" and pickupESPEnabled.hp
        if isAmmo or isHP then buildPickupESPFor(v) end
    end
end

local chamParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

local function applyChams(pl)
    if pl == lp then return end
    local c = pl.Character
    if not c then return end
    local mat = Enum.Material[flags["chams_material"] or "Neon"]
    for _, name in ipairs(chamParts) do
        local p = c:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            pcall(function()
                if not p:GetAttribute("__lx_mat") then
                    p:SetAttribute("__lx_mat", p.Material.Name)
                    p:SetAttribute("__lx_colR", p.Color.R)
                    p:SetAttribute("__lx_colG", p.Color.G)
                    p:SetAttribute("__lx_colB", p.Color.B)
                end
                p.Material = mat
                p.Color = state.colors.chams
            end)
        end
    end
end

local function removeChams(pl)
    local c = pl and pl.Character
    if not c then return end
    for _, name in ipairs(chamParts) do
        local p = c:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            pcall(function()
                local m = p:GetAttribute("__lx_mat")
                local cr, cg, cb = p:GetAttribute("__lx_colR"), p:GetAttribute("__lx_colG"), p:GetAttribute("__lx_colB")
                if m then p.Material = Enum.Material[m]; p:SetAttribute("__lx_mat", nil) end
                if cr and cg and cb then p.Color = Color3.new(cr, cg, cb); p:SetAttribute("__lx_colR", nil); p:SetAttribute("__lx_colG", nil); p:SetAttribute("__lx_colB", nil) end
            end)
        end
    end
end

local function reapplyAllChams()
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp then 
            if flags["chams_on"] then applyChams(pl) else removeChams(pl) end 
        end
    end
end

local hitboxOrigSizes = {}
local hitboxParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}

local function expandHitbox(pl)
    if pl == lp then return end
    local c = pl.Character
    if not c then return end
    hitboxOrigSizes[pl] = hitboxOrigSizes[pl] or {}
    local sz = flags["hitbox_size"] or 8
    for _, name in ipairs(hitboxParts) do
        local part = c:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if not hitboxOrigSizes[pl][name] then hitboxOrigSizes[pl][name] = part.Size end
            pcall(function() part.Size = Vector3.new(sz, sz, sz) end)
        end
    end
end

local function restoreHitbox(pl)
    local data = hitboxOrigSizes[pl]
    if not data then return end
    local c = pl and pl.Character
    if c then
        for name, orig in pairs(data) do
            local part = c:FindFirstChild(name)
            if part and part:IsA("BasePart") then pcall(function() part.Size = orig end) end
        end
    end
    hitboxOrigSizes[pl] = nil
end

local function updateAllHitboxes()
    local active = flags["hitbox_on"] or flags["silent_aim"]
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp then 
            if active then expandHitbox(pl) else restoreHitbox(pl) end 
        end
    end
end

local hbCounter = 0
connect(run.Heartbeat, function()
    if not (flags["hitbox_on"] or flags["silent_aim"]) then return end
    hbCounter = hbCounter + 1
    if hbCounter % 6 == 0 then updateAllHitboxes() end
end)

local myOrigSizes = {}
local function applyAntiAim()
    local c = getChar()
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hb = c:FindFirstChild("Hitbox")
    if hrp then
        if not myOrigSizes["hrp"] then myOrigSizes["hrp"] = hrp.Size end
        if hrp.Size ~= Vector3.new(0.5, 0.5, 0.5) then hrp.Size = Vector3.new(0.5, 0.5, 0.5) end
    end
    if hb then
        if not myOrigSizes["hb"] then myOrigSizes["hb"] = hb.Size end
        if hb.Size ~= Vector3.new(0.1, 0.1, 0.1) then hb.Size = Vector3.new(0.1, 0.1, 0.1) end
    end
end

local function removeAntiAim()
    local c = getChar()
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hb = c:FindFirstChild("Hitbox")
    if hrp and myOrigSizes["hrp"] then hrp.Size = myOrigSizes["hrp"] end
    if hb and myOrigSizes["hb"] then hb.Size = myOrigSizes["hb"] end
    myOrigSizes = {}
end

local function findClosestPartFromCursor()
    local mp = uis:GetMouseLocation()
    local closestDist, closest = math.huge, nil
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp and (not flags["aim_team_check"] or pl.Team ~= lp.Team) and is_spawned(lp) and is_spawned(pl) then
            local c = pl.Character
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if c and h and h.Health > 0 then
                for _, part in ipairs(c:GetChildren()) do
                    if part:IsA("BasePart") then
                        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                            if d < closestDist then closestDist = d; closest = part end
                        end
                    end
                end
            end
        end
    end
    state.aim_target_part = closest
end

connect(run.RenderStepped, function()
    if flags["silent_aim"] then findClosestPartFromCursor() else state.aim_target_part = nil end
end)

local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and flags["silent_aim"] and state.aim_target_part then
        local targetPart = state.aim_target_part
        if targetPart and targetPart.Parent and targetPart.Parent:IsDescendantOf(ws) then
            if method == "Raycast" and self == ws then
                args[1] = cam.CFrame.Position
                args[2] = (targetPart.Position - cam.CFrame.Position)
            elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                args[1] = Ray.new(cam.CFrame.Position, (targetPart.Position - cam.CFrame.Position).Unit * 600)
            end
        end
    end
    
    return oldNameCall(self, table.unpack(args))
end))

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() and flags["silent_aim"] then
        local ok, isMouse = pcall(function() return typeof(self) == "Instance" and self:IsA("Mouse") end)
        if ok and isMouse and state.aim_target_player then
            local t = state.aim_target_player
            if t and t.Character then
                local h = t.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    local partName = flags["aim_part"] or "Head"
                    local part = t.Character:FindFirstChild(partName) or t.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        local ok2, pos = pcall(function() return part.Position end)
                        if ok2 and pos then
                            if key == "Hit" then return CFrame.new(pos) end
                            if key == "Target" then return part end
                            if key == "UnitRay" then return Ray.new(cam.CFrame.Position, (pos - cam.CFrame.Position).Unit * 1000) end
                        end
                    end
                end
            end
        end
    end
    return oldIndex(self, key)
end))

local hitNotifConns = {}
local function clearHitNotifs()
    for _, conns in pairs(hitNotifConns) do
        for _, c in ipairs(conns) do
            pcall(function() c:Disconnect() end)
        end
    end
    hitNotifConns = {}
end

local function hookHitNotifs(plr)
    if plr == lp then return end
    if hitNotifConns[plr] then 
        for _, c in ipairs(hitNotifConns[plr]) do pcall(function() c:Disconnect() end) end
    end
    hitNotifConns[plr] = {}
    
    local function charAdded(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        
        local lastHealth = hum.Health
        local healthConn = connect(hum.HealthChanged, function(newHealth)
            if newHealth < lastHealth and flags["hit_notifs"] then
                local dmg = lastHealth - newHealth
                local timeSinceClick = tick() - (state.lastClickTime or 0)
                
                if timeSinceClick <= 0.15 and state.lookingAtPlayer == plr then
                    local partName = state.lookingAtPart or "body"
                    if partName == "Particle Area" or partName == "Hitbox" then
                        partName = "body"
                    end
                    library:notification({text = "hit that bitch "..plr.Name.." for "..math.floor(dmg).." hp in the "..partName.."!"})
                end
            end
            lastHealth = newHealth
        end)
        table.insert(hitNotifConns[plr], healthConn)
    end

    if plr.Character then charAdded(plr.Character) end
    table.insert(hitNotifConns[plr], connect(plr.CharacterAdded, charAdded))
end

for _, plr in ipairs(plrs:GetPlayers()) do hookHitNotifs(plr) end
connect(plrs.PlayerAdded, hookHitNotifs)

connect(uis.InputBegan, function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        state.lastClickTime = tick()
    end
end)

local function applyArmSkin()
    local arms = ws.Camera:FindFirstChild("Arms")
    if not arms then return end
    for _, v in ipairs(arms:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name == "Right Arm" or v.Name == "Left Arm" or v.Name == "RightHand" or v.Name == "LeftHand" or v.Name == "RightArm" or v.Name == "LeftArm") then
            pcall(function() v.Material = Enum.Material[state.skinMats.arm]; v.Color = state.skinColors.arm end)
        end
    end
end

local function applyGunSkin()
    local arms = ws.Camera:FindFirstChild("Arms")
    if not arms then return end
    for _, v in ipairs(arms:GetDescendants()) do
        if v:IsA("MeshPart") then 
            pcall(function() v.Material = Enum.Material[state.skinMats.gun]; v.Color = state.skinColors.gun end) 
        end
    end
end

local window = library:window({ name = "lunar x | arsenal", size = UDim2.fromOffset(580, 600) })

local aimbotTab = window:tab({ name = "aimbot" })
local visualsTab = window:tab({ name = "visuals" })
local movementTab = window:tab({ name = "movement" })
local weaponTab = window:tab({ name = "weapon" })
local skinsTab = window:tab({ name = "skins" })
local miscTab = window:tab({ name = "misc" })
local settingsTab = window:tab({ name = "settings" })

local aimbotSec = aimbotTab:section({ name = "aimbot", side = "left" })
local aimCfg = aimbotTab:section({ name = "aim config", side = "left" })
local fovSec = aimbotTab:section({ name = "fov circle", side = "right" })
local hbSec = aimbotTab:section({ name = "hitbox expander", side = "right" })
local indSec = aimbotTab:section({ name = "target indicator", side = "right" })
local trigCfg = aimbotTab:section({ name = "trigger config", side = "right" })

aimbotSec:toggle({ name = "Aimbot", flag = "aim_on", default = false })
aimbotSec:keybind({ name = "Aimbot Bind", flag = "aim_key", default = Enum.KeyCode.E, mode = "hold", callback = function(v) keybinds.aim = v end })

aimbotSec:toggle({ name = "Silent Aim", flag = "silent_aim", default = false, callback = function(v)
    if v then 
        updateAllHitboxes() 
    else
        for _, pl in ipairs(plrs:GetPlayers()) do restoreHitbox(pl) end
        state.aim_target_part = nil; state.aim_target_player = nil
    end
end})

aimbotSec:toggle({ name = "Trigger Bot", flag = "triggerbot", default = false })
aimbotSec:keybind({ name = "Trigger Bind", flag = "trigger_key", default = Enum.KeyCode.Q, mode = "hold", callback = function(v) keybinds.trigger = v end })

aimbotSec:toggle({ name = "Hit Notifications", flag = "hit_notifs", default = true })
aimbotSec:toggle({ name = "Team Check", flag = "aim_team_check", default = false })
aimbotSec:toggle({ name = "Wall Check", flag = "wall_check", default = true })
aimbotSec:toggle({ name = "Prediction", flag = "aim_prediction", default = false })

aimCfg:dropdown({ name = "Target Part", flag = "aim_part", items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftArm", "RightArm"}, default = "Head" })
aimCfg:dropdown({ name = "Priority", flag = "aim_priority", items = {"Nearest Mouse", "Nearest Distance", "Lowest HP"}, default = "Nearest Mouse" })
aimCfg:slider({ name = "Smoothness", flag = "aim_smooth", min = 0.01, max = 1, default = 0.15, interval = 0.01, suffix = "x" })
aimCfg:slider({ name = "Max Distance", flag = "aim_max_dist", min = 50, max = 2000, default = 500, interval = 10, suffix = " st" })
aimCfg:slider({ name = "Hit Chance", flag = "aim_hit_chance", min = 1, max = 100, default = 100, interval = 1, suffix = "%" })
aimCfg:slider({ name = "Pred Offset", flag = "aim_pred_val", min = 0, max = 1, default = 0.1, interval = 0.01, suffix = "s" })

fovSec:toggle({ name = "Visible", flag = "fov_visible", default = false, callback = function(v) fovCircle.Visible = v end })
fovSec:toggle({ name = "Filled", flag = "fov_filled", default = false, callback = function(v) fovCircle.Filled = v end })
fovSec:colorpicker({ name = "FOV Color", flag = "fov_color", color = state.colors.fov, alpha = 0, callback = function(c, t)
    state.colors.fov = c; state.colors.fovTr = t; fovCircle.Color = c; fovCircle.Transparency = t
end})
fovSec:slider({ name = "Radius", flag = "fov_radius", min = 10, max = 600, default = 150, interval = 5, suffix = "px", callback = function(v) fovCircle.Radius = v end })
fovSec:slider({ name = "Thickness", flag = "fov_thickness", min = 1, max = 5, default = 1, interval = 1, suffix = "px", callback = function(v) fovCircle.Thickness = v end })

hbSec:toggle({ name = "Hitbox Expander", flag = "hitbox_on", default = false, callback = function(v)
    if v then updateAllHitboxes() else for _, pl in ipairs(plrs:GetPlayers()) do restoreHitbox(pl) end end
end})
hbSec:slider({ name = "Hitbox Size", flag = "hitbox_size", min = 1, max = 60, default = 8, interval = 0.5, suffix = " st", callback = function()
    if flags["hitbox_on"] or flags["silent_aim"] then updateAllHitboxes() end
end})

indSec:toggle({ name = "Snap Line", flag = "snap_line", default = false })
indSec:colorpicker({ name = "Snap Color", flag = "snap_line_color", color = state.colors.snapLine, alpha = 0, callback = function(c)
    state.colors.snapLine = c; for _, d in pairs(espObjects) do d.snapLine.Color = c end
end})
indSec:slider({ name = "Thickness", flag = "snap_thickness", min = 1, max = 5, default = 1, interval = 1, suffix = "px", callback = function(v) state.colors.snapThick = v end })

trigCfg:slider({ name = "Trigger Delay", flag = "trigger_delay", min = 0.0001, max = 0.5, default = 0.01, interval = 0.0001, suffix = "s" })
trigCfg:slider({ name = "Trigger FOV", flag = "trigger_fov", min = 1, max = 300, default = 80, interval = 1, suffix = "px" })

local espSec = visualsTab:section({ name = "player esp", side = "left" })
local pickupSec = visualsTab:section({ name = "pickup esp", side = "left" })
local xhairSec = visualsTab:section({ name = "custom crosshair", side = "left" })
local worldSec = visualsTab:section({ name = "world", side = "right" })
local hlSec = visualsTab:section({ name = "highlights", side = "right" })
local chamsSec = visualsTab:section({ name = "chams", side = "right" })
local skinsSec = visualsTab:section({ name = "color skins", side = "right" })

espSec:toggle({ name = "ESP Enabled", flag = "esp_on", default = false })
espSec:toggle({ name = "Team Check", flag = "esp_team_check", default = true })
espSec:toggle({ name = "Wall Check", flag = "esp_wall_check", default = false })
espSec:slider({ name = "Max Distance", flag = "esp_max_dist", min = 50, max = 3000, default = 800, interval = 50, suffix = " st" })
espSec:dropdown({ name = "Box Style", flag = "box_style", items = {"None", "Full Box", "Corner Box"}, default = "Corner Box" })

espSec:toggle({ name = "Box ESP", flag = "box_esp", default = true })
espSec:colorpicker({ name = "Box Color", flag = "box_color", color = state.colors.box, alpha = 0, callback = function(c)
    state.colors.box = c
    for _, d in pairs(espObjects) do 
        d.box.Color = c
        for _, l in ipairs(d.corners) do l.Color = c end 
    end
end})
espSec:toggle({ name = "Filled", flag = "box_fill", default = false })
espSec:colorpicker({ name = "Fill Color", flag = "box_fill_color", color = state.colors.boxFill, alpha = 0.5, callback = function(c, a)
    state.colors.boxFill = c
    for _, d in pairs(espObjects) do d.boxFill.Color = c end
end})
espSec:slider({ name = "Fill Transparency", flag = "box_fill_trans", min = 0, max = 1, default = 0.5, interval = 0.05, suffix = "a", callback = function(v)
    state.colors.boxFillTr = v
    for _, d in pairs(espObjects) do d.boxFill.Transparency = v end
end})

espSec:toggle({ name = "Tracers", flag = "tracers_on", default = false })
espSec:colorpicker({ name = "Tracer Color", flag = "tracer_color", color = state.colors.tracer, alpha = 0, callback = function(c)
    state.colors.tracer = c; for _, d in pairs(espObjects) do d.tracer.Color = c end
end})
espSec:dropdown({ name = "Origin", flag = "tracer_origin", items = {"Bottom", "Center", "Top", "Mouse"}, default = "Bottom" })
espSec:slider({ name = "Thickness", flag = "tracer_thick", min = 1, max = 4, default = 1, interval = 1, suffix = "px", callback = function(v) state.colors.tracerThick = v end })

espSec:toggle({ name = "Name ESP", flag = "name_esp", default = false })
espSec:colorpicker({ name = "Name Color", flag = "name_color", color = state.colors.name, alpha = 0, callback = function(c)
    state.colors.name = c; for _, d in pairs(espObjects) do d.nameText.Color = c end
end})

espSec:toggle({ name = "Distance ESP", flag = "dist_esp", default = false })
espSec:colorpicker({ name = "Distance Color", flag = "dist_color", color = state.colors.dist, alpha = 0, callback = function(c)
    state.colors.dist = c; for _, d in pairs(espObjects) do d.distText.Color = c end
end})

espSec:toggle({ name = "Weapon ESP", flag = "weapon_esp", default = false })
espSec:colorpicker({ name = "Weapon Color", flag = "weapon_color", color = state.colors.weapon, alpha = 0, callback = function(c)
    state.colors.weapon = c; for _, d in pairs(espObjects) do d.weaponText.Color = c end
end})

espSec:toggle({ name = "Placement ESP", flag = "placement_esp", default = false })
espSec:colorpicker({ name = "Placement Color", flag = "placement_color", color = state.colors.placement, alpha = 0, callback = function(c)
    state.colors.placement = c; for _, d in pairs(espObjects) do d.placementText.Color = c end
end})

espSec:toggle({ name = "Health Bar", flag = "hp_esp", default = false })
espSec:toggle({ name = "Color by HP", flag = "hp_color_gradient", default = true })
espSec:toggle({ name = "Show HP Text", flag = "hp_text", default = false })

espSec:toggle({ name = "Skeleton ESP", flag = "skel_esp", default = false })
espSec:colorpicker({ name = "Skeleton Color", flag = "skel_color", color = state.colors.skel, alpha = 0, callback = function(c)
    state.colors.skel = c; for _, d in pairs(espObjects) do for _, l in ipairs(d.skeleton) do l.Color = c end end
end})

pickupSec:toggle({ name = "Ammo Box ESP", flag = "ammo_box_esp", default = false, callback = function(v)
    pickupESPEnabled.ammo = v
    if not v then 
        for obj, d in pairs(pickupESPObjects) do 
            if obj and obj.Name == "DeadAmmo" then removePickupDraw(d); pickupESPObjects[obj] = nil end 
        end 
    end
end})
pickupSec:toggle({ name = "HP Jug ESP", flag = "hp_jug_esp", default = false, callback = function(v)
    pickupESPEnabled.hp = v
    if not v then 
        for obj, d in pairs(pickupESPObjects) do 
            if obj and obj.Name == "DeadHP" then removePickupDraw(d); pickupESPObjects[obj] = nil end 
        end 
    end
end})

xhairSec:toggle({ name = "Crosshair", flag = "xhair_on", default = false, callback = function(v)
    if not v then for _, l in pairs(xhairLines) do l.Visible = false end end
end})
xhairSec:slider({ name = "Size", flag = "xhair_size", min = 2, max = 30, default = 10, interval = 1, suffix = "px" })
xhairSec:slider({ name = "Gap", flag = "xhair_gap", min = 0, max = 15, default = 3, interval = 1, suffix = "px" })
xhairSec:slider({ name = "Thickness", flag = "xhair_thick", min = 1, max = 5, default = 2, interval = 1, suffix = "px" })
xhairSec:toggle({ name = "Dot", flag = "xhair_dot", default = true })
xhairSec:colorpicker({ name = "Color", flag = "xhair_color", color = state.colors.xhair, alpha = 0, callback = function(c)
    state.colors.xhair = c; for _, l in pairs(xhairLines) do l.Color = c end
end})

worldSec:toggle({ name = "Fullbright", flag = "fullbright", default = false, callback = function(v)
    if v then 
        light.Ambient = rgb(178, 178, 178); light.Brightness = 2
    else 
        light.Ambient = lightOrig.Ambient; light.Brightness = desiredBrightness; light.ClockTime = desiredClockTime 
    end
end})
worldSec:toggle({ name = "Remove Fog", flag = "remove_fog", default = false, callback = function(v)
    light.FogEnd = v and 1e6 or lightOrig.FogEnd; light.FogStart = v and 1e6 or lightOrig.FogStart
end})
worldSec:toggle({ name = "No Particles", flag = "no_particles", default = false, callback = function(v)
    local atmo = light:FindFirstChildOfClass("Atmosphere")
    if atmo then atmo.Density = v and 0 or 0.395 end
    for _, obj in ipairs(ws:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled = not v end
    end
end})
worldSec:slider({ name = "Brightness", flag = "world_brightness", min = 0, max = 5, default = 1, interval = 0.1, suffix = "x", callback = function(v)
    desiredBrightness = v; if not flags["fullbright"] then light.Brightness = v end
end})
worldSec:slider({ name = "Time of Day", flag = "time_of_day", min = 0, max = 24, default = 14, interval = 0.5, suffix = "h", callback = function(v)
    desiredClockTime = v; if not flags["fullbright"] then light.ClockTime = v end
end})

hlSec:toggle({ name = "Highlight Enemies", flag = "highlight_enemies", default = false, callback = function(v)
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp and pl.Character then
            local ex = pl.Character:FindFirstChild("LunarHL")
            if v and not ex then
                local h = Instance.new("Highlight")
                h.Name = "LunarHL"; h.FillColor = state.colors.hlEnemy; h.OutlineColor = rgb(255, 255, 255); h.FillTransparency = 0.5; h.Parent = pl.Character
            elseif not v and ex then ex:Destroy() end
        end
    end
end})
hlSec:colorpicker({ name = "HL Enemy Fill", flag = "hl_enemy_fill", color = state.colors.hlEnemy, alpha = 0.5, callback = function(c)
    state.colors.hlEnemy = c
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp and pl.Character then
            local ex = pl.Character:FindFirstChild("LunarHL")
            if ex then ex.FillColor = c end
        end
    end
end})
hlSec:toggle({ name = "Highlight Self", flag = "highlight_self", default = false, callback = function(v)
    local c = getChar(); if not c then return end
    local ex = c:FindFirstChild("LunarSelfHL")
    if v and not ex then
        local h = Instance.new("Highlight")
        h.Name = "LunarSelfHL"; h.FillColor = hex("#AA55EB"); h.OutlineColor = rgb(255, 255, 255); h.FillTransparency = 0.6; h.Parent = c
    elseif not v and ex then ex:Destroy() end
end})

chamsSec:toggle({ name = "Chams", flag = "chams_on", default = false, callback = function(v)
    if v then reapplyAllChams() else for _, pl in ipairs(plrs:GetPlayers()) do removeChams(pl) end end
end})
chamsSec:dropdown({ name = "Material", flag = "chams_material", items = {"Neon", "ForceField", "SmoothPlastic", "Glass"}, default = "Neon", callback = function()
    if flags["chams_on"] then for _, pl in ipairs(plrs:GetPlayers()) do removeChams(pl); applyChams(pl) end end
end})
chamsSec:colorpicker({ name = "Chams Color", flag = "chams_color", color = state.colors.chams, alpha = 0, callback = function(c)
    state.colors.chams = c; if flags["chams_on"] then reapplyAllChams() end
end})

skinsSec:toggle({ name = "Arm Charms", flag = "arm_charm", default = false, callback = function(v) state.armSkinOn = v end })
skinsSec:dropdown({ name = "Arm Material", flag = "arm_mat", items = {"Plastic", "Neon", "ForceField", "Wood", "Grass", "SmoothPlastic"}, default = "Plastic", callback = function(v) state.skinMats.arm = v end })
skinsSec:colorpicker({ name = "Arm Color", flag = "arm_color", color = rgb(50, 50, 50), alpha = 0, callback = function(c) state.skinColors.arm = c end })

skinsSec:toggle({ name = "Gun Charms", flag = "gun_charm", default = false, callback = function(v) state.gunSkinOn = v end })
skinsSec:dropdown({ name = "Gun Material", flag = "gun_mat", items = {"Plastic", "Neon", "ForceField", "Wood", "Grass", "SmoothPlastic"}, default = "Plastic", callback = function(v) state.skinMats.gun = v end })
skinsSec:colorpicker({ name = "Gun Color", flag = "gun_color", color = rgb(50, 50, 50), alpha = 0, callback = function(c) state.skinColors.gun = c end })

skinsSec:toggle({ name = "Rainbow Gun", flag = "rainbow_gun", default = false, callback = function(v) state.rainbowOn = v; state.rainbowHue = 0 end })

local speedSec = movementTab:section({ name = "speed", side = "left" })
local jumpSec = movementTab:section({ name = "jump", side = "left" })
local gravSec = movementTab:section({ name = "gravity", side = "left" })
local flySec = movementTab:section({ name = "fly", side = "right" })
local miscMove = movementTab:section({ name = "misc movement", side = "right" })
local blinkSec = movementTab:section({ name = "blink", side = "right" })

speedSec:toggle({ name = "Speed Hack", flag = "speed_on", default = false, callback = function(v) apply_walkspeed(v, flags["walkspeed"] or 50) end })
speedSec:slider({ name = "WalkSpeed", flag = "walkspeed", min = 8, max = 500, default = 50, interval = 1, suffix = " ws", callback = function(v) if flags["speed_on"] then apply_walkspeed(true, v) end end })

jumpSec:toggle({ name = "Jump Hack", flag = "jump_on", default = false, callback = function(v) apply_jumppower(v, flags["jump_power"] or 50) end })
jumpSec:slider({ name = "JumpPower", flag = "jump_power", min = 7, max = 500, default = 50, interval = 1, suffix = " jp", callback = function(v) if flags["jump_on"] then apply_jumppower(true, v) end end })

jumpSec:toggle({ name = "Infinite Jump", flag = "inf_jump", default = false })

gravSec:toggle({ name = "Custom Gravity", flag = "custom_gravity", default = false, callback = function(v) pcall(function() rs.CurrentGrav.Value = v and (flags["gravity_val"] or 56) or 56 end) end })
gravSec:slider({ name = "Gravity", flag = "gravity_val", min = 1, max = 400, default = 56, interval = 1, suffix = " g", callback = function(v) if flags["custom_gravity"] then pcall(function() rs.CurrentGrav.Value = v end) end end })

local flyConn, bodyVel, bodyGyro
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
end
local function startFly()
    stopFly()
    local r = getRoot(); if not r then return end
    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.zero; bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5); bodyVel.Parent = r
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5); bodyGyro.P = 1e4; bodyGyro.Parent = r
    flyConn = connect(run.RenderStepped, function()
        if not flags["fly_on"] then stopFly(); return end
        local r2 = getRoot(); if not r2 then stopFly(); return end
        local dir = Vector3.zero
        if uis:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
        bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * (flags["fly_speed"] or 60) or Vector3.zero
        bodyGyro.CFrame = cam.CFrame
    end)
end

flySec:toggle({ name = "Fly", flag = "fly_on", default = false, callback = function(v)
    local h = getHum()
    if v then 
        if h then h.PlatformStand = true end; startFly()
    else 
        stopFly(); if h then h.PlatformStand = false end 
    end
end})
flySec:keybind({ name = "Fly Bind", flag = "fly_key", default = Enum.KeyCode.F, mode = "hold", callback = function(v)
    keybinds.fly = v; flags["fly_on"] = v
    local h = getHum()
    if v then 
        if h then h.PlatformStand = true end; startFly()
    else 
        stopFly(); if h then h.PlatformStand = false end 
    end
end})
flySec:slider({ name = "Fly Speed", flag = "fly_speed", min = 5, max = 300, default = 60, interval = 5, suffix = " sp" })

local noclipConn
miscMove:toggle({ name = "No Clip", flag = "noclip_on", default = false, callback = function(v)
    if v then
        noclipConn = connect(run.Stepped, function()
            if not flags["noclip_on"] then noclipConn:Disconnect(); noclipConn = nil; return end
            local c = getChar(); if not c then return end
            for _, p in ipairs(c:GetDescendants()) do 
                if p:IsA("BasePart") then p.CanCollide = false end 
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end})
miscMove:toggle({ name = "Anti-AFK", flag = "anti_afk", default = false })

blinkSec:toggle({ name = "Blink", flag = "blink_on", default = false })
blinkSec:keybind({ name = "Blink Bind", flag = "blink_key", default = Enum.KeyCode.X, mode = "hold", callback = function(v)
    keybinds.blink = v
    if v and flags["blink_on"] then 
        local r = getRoot(); 
        if r then r.CFrame = r.CFrame * CFrame.new(0, 0, -(flags["blink_dist"] or 40)) end 
    end
end})
blinkSec:slider({ name = "Distance", flag = "blink_dist", min = 5, max = 200, default = 40, interval = 5, suffix = " st" })

local weaponMod = weaponTab:section({ name = "weapon mods", side = "left" })
local combatSec = weaponTab:section({ name = "combat", side = "right" })

local function getWeapons() 
    local w = rs:FindFirstChild("Weapons")
    return w and w:GetChildren() or {} 
end

local origWV = {}
local function saveWV(w, n) 
    origWV[w] = origWV[w] or {}
    local o = w:FindFirstChild(n)
    if o and origWV[w][n] == nil then origWV[w][n] = o.Value end 
end
local function restoreWV(w, n) 
    local o = w:FindFirstChild(n)
    if o and origWV[w] and origWV[w][n] ~= nil then pcall(function() o.Value = origWV[w][n] end) end 
end
local function applyToWeapons(names, valFn, v)
    for _, w in ipairs(getWeapons()) do
        for _, n in ipairs(names) do
            local obj = w:FindFirstChild(n)
            if obj then 
                if v then saveWV(w, n); pcall(function() obj.Value = valFn() end) else restoreWV(w, n) end 
            end
        end
    end
end

weaponMod:toggle({ name = "No Spread", flag = "no_spread", default = false, callback = function(v) applyToWeapons({"Spread", "MaxSpread", "MinSpread", "Bloom", "SpreadControl"}, function() return 0 end, v) end })
weaponMod:toggle({ name = "No Recoil", flag = "no_recoil", default = false, callback = function(v)
    applyToWeapons({"RecoilControl", "RecoilMax", "RecoilMin", "Recoil"}, function() return 0 end, v)
    for _, w in ipairs(getWeapons()) do
        local rp = w:FindFirstChild("RecoilPunch")
        if rp then 
            if v then saveWV(w, "RecoilPunch"); pcall(function() rp.Value = Vector3.zero end) else restoreWV(w, "RecoilPunch") end 
        end
    end
end})
weaponMod:toggle({ name = "Rapid Fire", flag = "rapid_fire", default = false, callback = function(v) applyToWeapons({"FireRate", "BFireRate"}, function() return 0.02 end, v) end })
weaponMod:toggle({ name = "Always Auto", flag = "always_auto", default = false, callback = function(v) applyToWeapons({"Auto", "AutoFire", "Automatic", "AutoShoot", "AutoGun"}, function() return true end, v) end })
weaponMod:toggle({ name = "Fast Reload", flag = "fast_reload", default = false, callback = function(v) applyToWeapons({"ReloadTime", "EReloadTime"}, function() return 0.01 end, v) end })

weaponMod:toggle({ name = "Custom Fire Rate", flag = "custom_fire_rate_on", default = false, callback = function(v)
    if v then
        for _, w in ipairs(getWeapons()) do
            for _, n in ipairs({"FireRate", "BFireRate"}) do 
                local o = w:FindFirstChild(n)
                if o then saveWV(w, n); pcall(function() o.Value = flags["custom_fire_rate_val"] or 0.15 end) end 
            end
        end
    else
        for _, w in ipairs(getWeapons()) do 
            for _, n in ipairs({"FireRate", "BFireRate"}) do restoreWV(w, n) end 
        end
    end
end})
weaponMod:slider({ name = "Fire Rate Value", flag = "custom_fire_rate_val", min = 0.001, max = 1, default = 0.15, interval = 0.001, suffix = "s", callback = function(v)
    if flags["custom_fire_rate_on"] then
        for _, w in ipairs(getWeapons()) do
            for _, n in ipairs({"FireRate", "BFireRate"}) do 
                local o = w:FindFirstChild(n)
                if o then pcall(function() o.Value = v end) end 
            end
        end
    end
end})

local ammoVal = 677
local function setAllAmmo()
    for _, w in ipairs(getWeapons()) do 
        local o = w:FindFirstChild("Ammo")
        if o and o.Value ~= ammoVal then pcall(function() o.Value = ammoVal end) end 
    end
    pcall(function()
        local vars = lp.PlayerGui.GUI.Client.Variables
        if vars.ammocount.Value ~= ammoVal then vars.ammocount.Value = ammoVal end
        if vars.ammocount2.Value ~= ammoVal then vars.ammocount2.Value = ammoVal end
    end)
    pcall(function() 
        if flags["inf_ammo"] then rs.wkspc.CurrentCurse.Value = "Infinite Ammo" end 
    end)
end

local function hookWeaponAmmo(w)
    local o = w:FindFirstChild("Ammo")
    if not o then return end
    connect(o:GetPropertyChangedSignal("Value"), function() 
        if flags["inf_ammo"] and o.Value ~= ammoVal then pcall(function() o.Value = ammoVal end) end 
    end)
end

for _, w in ipairs(getWeapons()) do hookWeaponAmmo(w) end
local wf = rs:FindFirstChild("Weapons")
if wf then connect(wf.ChildAdded, function(w) task.wait(0.05); hookWeaponAmmo(w) end) end

local ammoCounter = 0
connect(run.Heartbeat, function()
    if not flags["inf_ammo"] then return end
    ammoCounter = ammoCounter + 1
    if ammoCounter % 3 == 0 then setAllAmmo() end
end)

weaponMod:toggle({ name = "Infinite Ammo", flag = "inf_ammo", default = false, callback = function(v) 
    if v then setAllAmmo() else pcall(function() rs.wkspc.CurrentCurse.Value = "" end) end 
end})

local killAllActive = false
local killAllThread = nil

local function getAliveEnemies()
    local list = {}
    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl ~= lp and (not flags["kill_team_check"] or pl.Team ~= lp.Team) and is_spawned(pl) then 
            table.insert(list, pl) 
        end
    end
    for i = #list, 2, -1 do 
        local j = math.random(1, i); list[i], list[j] = list[j], list[i] 
    end
    return list
end

local function runKillAll()
    local crouching = false
    while killAllActive do
        if is_spawned(lp) then
            local enemies = getAliveEnemies()
            if #enemies == 0 then 
                if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
                task.wait(0.5) 
            else
                for _, target in ipairs(enemies) do
                    if not killAllActive then 
                        if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
                        return 
                    end
                    if not is_spawned(target) then continue end

                    local r = getRoot()
                    local c = target.Character
                    local h = c and c:FindFirstChildOfClass("Humanoid")
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    local head = c and c:FindFirstChild("Head")
                    
                    if r and hrp and h and h.Health > 0 then
                        if (hrp.Position - r.Position).Magnitude > (flags["kill_max_dist"] or 1000) then continue end
                        if flags["kill_all_wall_check"] and not wall_check(c, hrp) then 
                            task.wait(0.1)
                            continue 
                        end

                        if flags["kill_auto_crouch"] and not crouching then
                            VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game)
                            crouching = true
                        end

                        local engageStart = tick()
                        local maxEngage = flags["kill_engage_time"] or 4
                        
                        while killAllActive and is_spawned(target) do
                            r = getRoot()
                            c = target.Character
                            h = c and c:FindFirstChildOfClass("Humanoid")
                            hrp = c and c:FindFirstChild("HumanoidRootPart")
                            head = c and c:FindFirstChild("Head")
                            
                            if not r or not c or not h or not hrp or not head then break end
                            if h.Health <= 0 then break end

                            if flags["kill_use_max_engage"] and (tick() - engageStart > maxEngage) then 
                                break 
                            end

                            local behindPos = hrp.Position - (hrp.CFrame.LookVector * 4.5)
                            r.CFrame = CFrame.new(behindPos, head.Position)
                            
                            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, head.Position)

                            state.aim_target_player = target
                            state.aim_target_part = head

                            if flags["kill_auto_knife"] then
                                VIM:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                                task.wait()
                                VIM:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                            end

                            if flags["kill_use_triggerbot"] then
                                mouse1press()
                                state.lastClickTime = tick() 
                                task.wait(0.02)
                                mouse1release()
                            end

                            task.wait(flags["kill_delay"] or 0.06)
                        end
                    else
                        if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
                    end
                    state.aim_target_player = nil
                    state.aim_target_part = nil
                end
            end
        else
            if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
        end
        task.wait(0.1)
    end
    if crouching then VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game); crouching = false end
end

local function setKillAll(active)
    killAllActive = active; flags["kill_all"] = active
    if killAllThread then task.cancel(killAllThread); killAllThread = nil end
    if active then killAllThread = task.spawn(runKillAll) end
end

combatSec:toggle({ name = "Kill All", flag = "kill_all", default = false, callback = function(v) setKillAll(v) end })
combatSec:keybind({ name = "Kill All Bind", flag = "kill_all_key", default = Enum.KeyCode.T, mode = "hold", callback = function(v) setKillAll(v) end })
combatSec:toggle({ name = "Team Check", flag = "kill_team_check", default = true })
combatSec:toggle({ name = "Wall Check", flag = "kill_all_wall_check", default = false })
combatSec:toggle({ name = "Auto Crouch", flag = "kill_auto_crouch", default = false })
combatSec:toggle({ name = "Auto Equip Knife", flag = "kill_auto_knife", default = false })
combatSec:toggle({ name = "Use Triggerbot", flag = "kill_use_triggerbot", default = true })
combatSec:toggle({ name = "Use Max Engage Time", flag = "kill_use_max_engage", default = true })
combatSec:slider({ name = "Max Distance", flag = "kill_max_dist", min = 50, max = 5000, default = 1000, interval = 50, suffix = " st" })
combatSec:slider({ name = "TP Delay", flag = "kill_delay", min = 0.001, max = 0.5, default = 0.06, interval = 0.001, suffix = "s" })
combatSec:slider({ name = "Max Engage Time", flag = "kill_engage_time", min = 0.5, max = 10, default = 4, interval = 0.5, suffix = "s" })

local spinConn
combatSec:toggle({ name = "Spin Bot", flag = "spin_on", default = false, callback = function(v)
    if v then
        spinConn = connect(run.RenderStepped, function(dt)
            if not flags["spin_on"] then spinConn:Disconnect(); spinConn = nil; return end
            local r = getRoot()
            if r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad((flags["spin_speed"] or 180) * dt), 0) end
        end)
    else
        if spinConn then spinConn:Disconnect(); spinConn = nil end
    end
end})
combatSec:slider({ name = "Spin Speed", flag = "spin_speed", min = 10, max = 720, default = 180, interval = 10, suffix = "°/s" })

combatSec:toggle({ name = "Anti-Aim", flag = "anti_aim_small", default = false })

local function getItems(category)
    local list = {}
    local folder = rs:FindFirstChild("ItemData") and rs.ItemData:FindFirstChild("Images") and rs.ItemData.Images:FindFirstChild(category)
    if folder then 
        for _, v in ipairs(folder:GetChildren()) do table.insert(list, v.Name) end 
    end
    table.sort(list)
    return list
end

local function updatePreview(vp, category, name)
    for _, c in ipairs(vp:GetChildren()) do 
        if c:IsA("ImageLabel") then c:Destroy() end 
    end
    local imgFolder = rs:FindFirstChild("ItemData") and rs.ItemData:FindFirstChild("Images") and rs.ItemData.Images:FindFirstChild(category)
    if not imgFolder then return end
    local imgObj = imgFolder:FindFirstChild(name)
    if not imgObj then return end
    library:create("ImageLabel", { Parent = vp, Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0.5, -50, 0.5, -50), BackgroundTransparency = 1, Image = imgObj.Value })
end

local meleeSec = skinsTab:section({ name = "melee", side = "left" })
local skinSec = skinsTab:section({ name = "skin", side = "right" })
local announcerSec = skinsTab:section({ name = "announcer", side = "left" })

local meleeVP = library:create("Frame", { Parent = meleeSec.holder, Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0 })
local skinVP = library:create("Frame", { Parent = skinSec.holder, Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0 })
local announcerVP = library:create("Frame", { Parent = announcerSec.holder, Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0 })

local meleeList = getItems("Melees")
local skinList = getItems("Skins")
local announcerList = getItems("Announcers")

local meleeDrop = meleeSec:dropdown({ name = "Select Melee", flag = "lx_melee", items = meleeList, default = meleeList[1] or "", callback = function(v) updatePreview(meleeVP, "Melees", v) end })
meleeSec:textbox({ flag = "search_melee", placeholder = "search...", callback = function(text)
    local filtered = {}
    for _, item in ipairs(meleeList) do 
        if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end 
    end
    meleeDrop:refresh_options(filtered)
end })
meleeSec:button({ name = "Apply Melee", callback = function() 
    local d = lp:FindFirstChild("Data")
    if d and d.Melee then pcall(function() d.Melee.Value = flags["lx_melee"] end) end 
end})

local skinDrop = skinSec:dropdown({ name = "Select Skin", flag = "lx_skin", items = skinList, default = skinList[1] or "", callback = function(v) updatePreview(skinVP, "Skins", v) end })
skinSec:textbox({ flag = "search_skin", placeholder = "search...", callback = function(text)
    local filtered = {}
    for _, item in ipairs(skinList) do 
        if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end 
    end
    skinDrop:refresh_options(filtered)
end })
skinSec:button({ name = "Apply Skin", callback = function()
    local d = lp:FindFirstChild("Data")
    if d and d.Skin then 
        pcall(function() d.Skin.Value = flags["lx_skin"]; if d.Skin:FindFirstChild("Sleeve") then d.Skin.Sleeve.Value = flags["lx_skin"] end end) 
    end
end})

local announcerDrop = announcerSec:dropdown({ name = "Select Announcer", flag = "lx_announcer", items = announcerList, default = announcerList[1] or "", callback = function(v) updatePreview(announcerVP, "Announcers", v) end })
announcerSec:textbox({ flag = "search_announcer", placeholder = "search...", callback = function(text)
    local filtered = {}
    for _, item in ipairs(announcerList) do 
        if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end 
    end
    announcerDrop:refresh_options(filtered)
end })
announcerSec:button({ name = "Apply Announcer", callback = function() 
    local d = lp:FindFirstChild("Data")
    if d and d.Announcer then pcall(function() d.Announcer.Value = flags["lx_announcer"] end) end 
end})

if meleeList[1] then updatePreview(meleeVP, "Melees", meleeList[1]) end
if skinList[1] then updatePreview(skinVP, "Skins", skinList[1]) end
if announcerList[1] then updatePreview(announcerVP, "Announcers", announcerList[1]) end

local miscSec = miscTab:section({ name = "local player", side = "left" })
local serverSec = miscTab:section({ name = "server", side = "left" })
local killfeedSec = miscTab:section({ name = "kill feed", side = "right" })

miscSec:toggle({ name = "Anti-afk", flag = "misc_anti_afk", default = false })
miscSec:toggle({ name = "Hide Character", flag = "hide_char", default = false, callback = function(v)
    local c = getChar(); if not c then return end
    for _, p in ipairs(c:GetDescendants()) do 
        if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier = v and 1 or 0 end 
    end
end})
miscSec:slider({ name = "Camera FOV", flag = "cam_fov", min = 40, max = 120, default = defaultFOV, interval = 1, suffix = "°", callback = function(v) 
    cam.FieldOfView = v; pcall(function() lp.Settings.FOV.Value = v end)
end})

miscSec:button({ 
    name = "Unlock All Crates", 
    callback = function()
        local pgui = lp:FindFirstChild("PlayerGui")
        if not pgui then return end
        local gui = pgui:FindFirstChild("Menew")
        if not gui then return end
        local shop = gui:FindFirstChild("Shop")
        if not shop then return end
        local cases = shop:FindFirstChild("Cases")
        if not cases then return end
        for _, case in pairs(cases:GetChildren()) do
            if case:IsA("GuiObject") then
                case.Visible = true
            end
        end
    end 
})

killfeedSec:toggle({ name = "Custom Kill Feed", flag = "killfeed_on", default = false })
killfeedSec:textbox({ name = "Killer", flag = "killfeed_killer", placeholder = "Killer name..." })
killfeedSec:textbox({ name = "Victim", flag = "killfeed_victim", placeholder = "Victim name..." })
killfeedSec:textbox({ name = "Assist", flag = "killfeed_assist", placeholder = "Assist name..." })

serverSec:button({ name = "Copy Server ID", callback = function() pcall(function() setclipboard(game.JobId) end) end })
serverSec:button({ name = "Rejoin Server", callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end })
serverSec:button({ name = "Server Hop", callback = function()
    pcall(function()
        local http = game:GetService("HttpService")
        local servers = http:JSONDecode(HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in ipairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, lp); break end
        end
    end)
end})

local cfgSec = settingsTab:section({ name = "configs", side = "left" })
local uiSec = settingsTab:section({ name = "ui", side = "right" })
local autoExecSec = settingsTab:section({ name = "auto execution", side = "right" })

local dir = library.directory .. "/configs/"
if not isfolder(library.directory) then makefolder(library.directory) end
if not isfolder(dir) then makefolder(dir) end

local function applyLoadedSkins()
    local data = lp:FindFirstChild("Data")
    if not data then return end
    if flags["lx_melee"] then
        pcall(function() data.Melee.Value = flags["lx_melee"] end)
    end
    if flags["lx_skin"] then
        pcall(function()
            data.Skin.Value = flags["lx_skin"]
            if data.Skin:FindFirstChild("Sleeve") then data.Skin.Sleeve.Value = flags["lx_skin"] end
        end)
    end
    if flags["lx_announcer"] then
        pcall(function() data.Announcer.Value = flags["lx_announcer"] end)
    end
end

library.config_holder = cfgSec:dropdown({ name = "Configs", flag = "config_name_list", items = {}, default = "" })
cfgSec:textbox({ name = "Config Name", flag = "config_name_text_box", placeholder = "config name" })

cfgSec:button({
    name = "Create",
    callback = function()
        local name = flags["config_name_text_box"]
        if name and name ~= "" then
            writefile(dir .. name .. ".cfg", library:get_config())
            library:config_list_update()
        end
    end
})
cfgSec:button({
    name = "Load",
    callback = function()
        local name = flags["config_name_list"]
        if name and name ~= "" then
            local path = dir .. name .. ".cfg"
            if isfile(path) then
                library:load_config(readfile(path))
                applyLoadedSkins()
                library:notification({text = "Loaded config: "..name})
            end
        end
    end
})
cfgSec:button({
    name = "Save",
    callback = function()
        local name = flags["config_name_list"] or flags["config_name_text_box"]
        if name and name ~= "" then
            writefile(dir .. name .. ".cfg", library:get_config())
            library:config_list_update()
            library:notification({text = "Saved config: "..name})
        end
    end
})
cfgSec:button({
    name = "Delete",
    callback = function()
        local name = flags["config_name_list"]
        if name and name ~= "" then
            local path = dir .. name .. ".cfg"
            if isfile(path) then
                delfile(path)
                library:config_list_update()
            end
        end
    end
})

cfgSec:button({
    name = "Auto Load This Config",
    callback = function()
        local name = flags["config_name_list"]
        if name and name ~= "" then
            local path = dir .. name .. ".cfg"
            if isfile(path) then
                writefile(library.directory .. "/autoload.cfg", name)
                library:notification({text = "Will auto load: " .. name})
            else
                library:notification({text = "Select a valid config first!"})
            end
        else
            library:notification({text = "Select a config first!"})
        end
    end
})

cfgSec:button({
    name = "Stop Auto Loading Config",
    callback = function()
        if isfile(library.directory .. "/autoload.cfg") then
            delfile(library.directory .. "/autoload.cfg")
            library:notification({text = "Auto load stopped"})
        end
    end
})

library:config_list_update()

autoExecSec:toggle({
    name = "Auto exec on Join",
    flag = "auto_exec_on_join",
    default = false,
    callback = function(v)
        if v then
            writefile(library.directory .. "/autoexec.cfg", "true")
            library:notification({text = "place this script in your autoexec folder if auto exec isnt working!"})
        else
            if isfile(library.directory .. "/autoexec.cfg") then
                delfile(library.directory .. "/autoexec.cfg")
            end
        end
    end
})

autoExecSec:toggle({
    name = "Silent load",
    flag = "silent_load",
    default = false,
    callback = function(v)
        if v then
            writefile(library.directory .. "/silentload.cfg", "true")
        else
            if isfile(library.directory .. "/silentload.cfg") then
                delfile(library.directory .. "/silentload.cfg")
            end
        end
    end
})

uiSec:toggle({ name = "Keybind List", flag = "ui_keybind_list", default = false, callback = function(v) window.toggle_list(v) end })
uiSec:toggle({ name = "Player List", flag = "ui_player_list", default = false, callback = function(v) window.toggle_playerlist(v) end })
uiSec:keybind({ name = "Menu Toggle", flag = "menu_key", default = Enum.KeyCode.RightControl, callback = function(v) window.set_menu_visibility(v) end })
uiSec:colorpicker({ name = "Accent Color", flag = "accent_color", color = defaultCol, alpha = 0, callback = function(c) library:update_theme("accent", c) end })
uiSec:button({ name = "Unload", callback = function()
    disconnect_all()
    clearHitNotifs()
    for pl, _ in pairs(espObjects) do destroyESP(pl) end
    for obj, d in pairs(pickupESPObjects) do removePickupDraw(d) end
    pickupESPObjects = {}
    fovCircle:Remove()
    for _, l in pairs(xhairLines) do l:Remove() end

    for _, pl in ipairs(plrs:GetPlayers()) do
        restoreHitbox(pl); removeChams(pl)
        if pl.Character then local ex = pl.Character:FindFirstChild("LunarHL"); if ex then ex:Destroy() end end
    end
    removeAntiAim()
    local c = getChar()
    if c then local ex = c:FindFirstChild("LunarSelfHL"); if ex then ex:Destroy() end end

    light.Ambient = lightOrig.Ambient
    light.Brightness = lightOrig.Brightness
    light.FogEnd = lightOrig.FogEnd
    light.FogStart = lightOrig.FogStart
    pcall(function() rs.CurrentGrav.Value = 56 end)
    pcall(function() lp.Settings.FOV.Value = defaultFOV end)
    apply_walkspeed(false, 16); apply_jumppower(false, 50)
    library:unload()
end})

local function getTarget()
    if not is_spawned(lp) then return nil end
    local mp = uis:GetMouseLocation()
    local fov = flags["fov_radius"] or 150
    local maxDist = flags["aim_max_dist"] or 500
    local root = getRoot()
    local best, bestScore = nil, math.huge

    for _, pl in ipairs(plrs:GetPlayers()) do
        if pl == lp then continue end
        if flags["aim_team_check"] and pl.Team == lp.Team then continue end
        if not is_spawned(pl) then continue end

        local c = pl.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local part = c and c:FindFirstChild(flags["aim_part"] or "Head")
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not (c and h and part and hrp and h.Health > 0) then continue end
        if root and (hrp.Position - root.Position).Magnitude > maxDist then continue end

        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local screenDist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        if screenDist > fov then continue end

        if not wall_check(c, part) then continue end

        local priority = flags["aim_priority"] or "Nearest Mouse"
        local score
        if priority == "Nearest Mouse" then score = screenDist
        elseif priority == "Nearest Distance" then score = root and (hrp.Position - root.Position).Magnitude or screenDist
        elseif priority == "Lowest HP" then score = h.Health end
        if score and score < bestScore then best = pl; bestScore = score end
    end
    return best
end

local function isEnemyPlayer(pl) 
    return not flags["aim_team_check"] or pl.Team ~= lp.Team 
end

local function hookTriggerHumanoid(char)
    local h = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if h then connect(h.HealthChanged, function(hp) state.triggerAlive = hp > 0 end) end
    state.triggerAlive = true
end
connect(lp.CharacterAdded, hookTriggerHumanoid)
if getChar() then hookTriggerHumanoid(getChar()) end

connect(run.RenderStepped, function(dt)
    local mp = uis:GetMouseLocation()
    local vp = cam.ViewportSize
    local espOn = flags["esp_on"]
    local rootPos = getRoot() and getRoot().Position

    if flags["anti_aim_small"] then
        applyAntiAim()
    else
        removeAntiAim()
    end

    local origin = cam.CFrame.Position
    local dir = cam.CFrame.LookVector * 1000
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {getChar()}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local hit = ws:Raycast(origin, dir, rp)
    if hit and hit.Instance then
        local char = hit.Instance:FindFirstAncestorWhichIsA("Model")
        if char then
            local plr = plrs:GetPlayerFromCharacter(char)
            if plr then
                state.lookingAtPlayer = plr
                state.lookingAtPart = hit.Instance.Name
            else
                state.lookingAtPlayer = nil
            end
        else
            state.lookingAtPlayer = nil
        end
    else
        state.lookingAtPlayer = nil
    end

    if flags["fov_visible"] then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(mp.X, mp.Y)
        fovCircle.Color = state.colors.fov
        fovCircle.Transparency = state.colors.fovTr
        fovCircle.Thickness = flags["fov_thickness"] or 1
        fovCircle.Filled = flags["fov_filled"] or false
        fovCircle.Radius = flags["fov_radius"] or 150
        fovCircle.NumSides = 60
    else
        fovCircle.Visible = false
    end

    local currentTarget = getTarget()
    state.aim_target_player = (flags["silent_aim"] and currentTarget) or nil

    if flags["aim_on"] and keybinds.aim and currentTarget and currentTarget.Character and is_spawned(currentTarget) then
        local part = currentTarget.Character:FindFirstChild(flags["aim_part"] or "Head")
        if part then
            local smooth = flags["aim_smooth"] or 0.15
            if math.random(1, 100) <= (flags["aim_hit_chance"] or 100) then
                local targetPos = part.Position
                if flags["aim_prediction"] then
                    local hrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then targetPos = targetPos + hrp.AssemblyLinearVelocity * (flags["aim_pred_val"] or 0.1) end
                end
                cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, targetPos), smooth)
            end
        end
    end

    if flags["triggerbot"] and state.triggerAlive and is_spawned(lp) then
        if keybinds.trigger then
            local now = tick()
            if now - state.triggerCooldown >= (flags["trigger_delay"] or 0.08) then
                local tgt = mouse.Target
                if tgt and tgt.Parent then
                    local h = tgt.Parent:FindFirstChild("Humanoid")
                    if h and tgt.Parent.Name ~= lp.Name and h.Health > 0 then
                        local tp = plrs:FindFirstChild(tgt.Parent.Name)
                        if tp and isEnemyPlayer(tp) and is_spawned(tp) then
                            mouse1press()
                            state.lastClickTime = tick() 
                            task.delay(flags["trigger_delay"] or 0.08, function() mouse1release() end)
                            state.triggerCooldown = now
                        end
                    end
                end
            end
        end
    end

    if flags["xhair_on"] then
        local cx, cy = vp.X / 2, vp.Y / 2
        local sz, gap, thk = flags["xhair_size"] or 10, flags["xhair_gap"] or 3, flags["xhair_thick"] or 2
        local col = state.colors.xhair
        local function setL(l, fx, fy, tx, ty) 
            l.From, l.To = Vector2.new(fx, fy), Vector2.new(tx, ty)
            l.Thickness, l.Color, l.Visible = thk, col, true 
        end
        setL(xhairLines.top, cx, cy - gap - sz, cx, cy - gap)
        setL(xhairLines.bottom, cx, cy + gap, cx, cy + gap + sz)
        setL(xhairLines.left, cx - gap - sz, cy, cx - gap, cy)
        setL(xhairLines.right, cx + gap, cy, cx + gap + sz, cy)
        xhairLines.dot.Visible = flags["xhair_dot"] == true
        xhairLines.dot.Position = Vector2.new(cx, cy)
        xhairLines.dot.Color = col
    else
        for _, l in pairs(xhairLines) do l.Visible = false end
    end

    for pl, d in pairs(espObjects) do
        local c = pl.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local hrp = c and c:FindFirstChild("HumanoidRootPart")

        local function hideAll()
            d.box.Visible = false; d.boxFill.Visible = false
            d.nameText.Visible = false; d.distText.Visible = false
            d.weaponText.Visible = false; d.placementText.Visible = false
            d.hpBG.Visible = false; d.hpBar.Visible = false; d.hpText.Visible = false
            d.tracer.Visible = false; d.snapLine.Visible = false
            for _, l in ipairs(d.corners) do l.Visible = false end
            for _, l in ipairs(d.skeleton) do l.Visible = false end
        end

        if not espOn or not c or not h or not hrp or h.Health <= 0 or not is_spawned(pl) then hideAll(); continue end
        if flags["esp_team_check"] and pl.Team == lp.Team then hideAll(); continue end
        if rootPos and (hrp.Position - rootPos).Magnitude > (flags["esp_max_dist"] or 800) then hideAll(); continue end

        local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then hideAll(); continue end
        if not esp_wall_check(c, hrp) then hideAll(); continue end

        local topSP = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local botSP = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
        local boxH = math.abs(botSP.Y - topSP.Y)
        local boxW = boxH * 0.55
        local bx, by = sp.X - boxW / 2, topSP.Y
        local style = flags["box_style"] or "Corner Box"

        if flags["box_esp"] then
            if style == "Full Box" then
                for _, l in ipairs(d.corners) do l.Visible = false end
                d.box.Size = Vector2.new(boxW, boxH); d.box.Position = Vector2.new(bx, by)
                d.box.Color = state.colors.box; d.box.Visible = true
            elseif style == "Corner Box" then
                d.box.Visible = false
                local cL = math.min(boxW, boxH) * 0.28
                local co = d.corners
                co[1].From, co[1].To = Vector2.new(bx, by), Vector2.new(bx + cL, by)
                co[2].From, co[2].To = Vector2.new(bx, by), Vector2.new(bx, by + cL)
                co[3].From, co[3].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW - cL, by)
                co[4].From, co[4].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW, by + cL)
                co[5].From, co[5].To = Vector2.new(bx, by + boxH), Vector2.new(bx + cL, by + boxH)
                co[6].From, co[6].To = Vector2.new(bx, by + boxH), Vector2.new(bx, by + boxH - cL)
                co[7].From, co[7].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW - cL, by + boxH)
                co[8].From, co[8].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW, by + boxH - cL)
                for _, l in ipairs(co) do l.Color = state.colors.box; l.Visible = true end
            else
                d.box.Visible = false
                for _, l in ipairs(d.corners) do l.Visible = false end
            end
        else
            d.box.Visible = false
            for _, l in ipairs(d.corners) do l.Visible = false end
        end

        if flags["box_esp"] and flags["box_fill"] then
            d.boxFill.Size = Vector2.new(boxW, boxH); d.boxFill.Position = Vector2.new(bx, by)
            d.boxFill.Color = state.colors.boxFill; d.boxFill.Transparency = state.colors.boxFillTr
            d.boxFill.Visible = true
        else 
            d.boxFill.Visible = false 
        end

        local yOffset = by - 14
        if flags["placement_esp"] then
            local placement = rs:FindFirstChild("Placement") and rs.Placement:FindFirstChild(pl.Name)
            if placement then
                d.placementText.Text = "#"..tostring(placement.Value)
                d.placementText.Position = Vector2.new(sp.X, yOffset)
                d.placementText.Color = state.colors.placement
                d.placementText.Visible = true
                yOffset = yOffset - 13
            else 
                d.placementText.Visible = false 
            end
        else 
            d.placementText.Visible = false 
        end

        if flags["name_esp"] then
            d.nameText.Text = pl.Name
            d.nameText.Position = Vector2.new(sp.X, yOffset)
            d.nameText.Color = state.colors.name
            d.nameText.Visible = true
            yOffset = yOffset - 13
        else 
            d.nameText.Visible = false 
        end

        if flags["weapon_esp"] then
            local tool = pl:FindFirstChild("NRPBS") and pl.NRPBS:FindFirstChild("EquippedTool")
            if tool then
                d.weaponText.Text = tostring(tool.Value)
                d.weaponText.Position = Vector2.new(sp.X, yOffset)
                d.weaponText.Color = state.colors.weapon
                d.weaponText.Visible = true
                yOffset = yOffset - 13
            else 
                d.weaponText.Visible = false 
            end
        else 
            d.weaponText.Visible = false 
        end

        if flags["dist_esp"] and rootPos then
            local dist = math.round((hrp.Position - rootPos).Magnitude)
            d.distText.Text = dist .. "m"
            d.distText.Position = Vector2.new(sp.X, by + boxH + 3)
            d.distText.Color = state.colors.dist
            d.distText.Visible = true
        else 
            d.distText.Visible = false 
        end

        if flags["hp_esp"] then
            local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
            local hbX, barH = bx - 6, boxH * pct
            d.hpBG.Size = Vector2.new(4, boxH); d.hpBG.Position = Vector2.new(hbX, by); d.hpBG.Visible = true
            d.hpBar.Size = Vector2.new(4, barH); d.hpBar.Position = Vector2.new(hbX, by + boxH - barH)
            d.hpBar.Color = flags["hp_color_gradient"] and Color3.fromRGB(math.round((1 - pct) * 255), math.round(pct * 255), 0) or Color3.fromRGB(0, 255, 0)
            d.hpBar.Visible = true
            if flags["hp_text"] then
                d.hpText.Text = tostring(math.floor(h.Health))
                d.hpText.Position = Vector2.new(hbX - 10, by + boxH - barH - 6)
                d.hpText.Visible = true
            else 
                d.hpText.Visible = false 
            end
        else
            d.hpBG.Visible = false; d.hpBar.Visible = false; d.hpText.Visible = false
        end

        if flags["tracers_on"] then
            local origin = flags["tracer_origin"] or "Bottom"
            local fromX = origin == "Mouse" and mp.X or vp.X / 2
            local fromY = (origin == "Top" and 0) or (origin == "Center" and vp.Y / 2) or (origin == "Mouse" and mp.Y) or vp.Y
            d.tracer.From = Vector2.new(fromX, fromY); d.tracer.To = Vector2.new(sp.X, sp.Y)
            d.tracer.Color = state.colors.tracer; d.tracer.Thickness = state.colors.tracerThick; d.tracer.Visible = true
        else 
            d.tracer.Visible = false 
        end

        if flags["snap_line"] and currentTarget == pl then
            d.snapLine.From = Vector2.new(vp.X / 2, vp.Y / 2); d.snapLine.To = Vector2.new(sp.X, sp.Y)
            d.snapLine.Color = state.colors.snapLine; d.snapLine.Thickness = state.colors.snapThick; d.snapLine.Visible = true
        else 
            d.snapLine.Visible = false 
        end

        if flags["skel_esp"] then
            for i, pair in ipairs(skel_pairs) do
                local p1 = c:FindFirstChild(pair[1]); local p2 = c:FindFirstChild(pair[2])
                local ln = d.skeleton[i]
                if p1 and p2 then
                    local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                    local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                    if on1 and on2 then
                        ln.From = Vector2.new(s1.X, s1.Y); ln.To = Vector2.new(s2.X, s2.Y)
                        ln.Color = state.colors.skel; ln.Visible = true
                    else 
                        ln.Visible = false 
                    end
                else 
                    ln.Visible = false 
                end
            end
        else
            for _, l in ipairs(d.skeleton) do l.Visible = false end
        end
    end

    if pickupESPEnabled.ammo or pickupESPEnabled.hp then
        refreshPickupESP()
        for obj, d in pairs(pickupESPObjects) do
            if not obj or not obj.Parent then continue end
            local isAmmoObj = obj.Name == "DeadAmmo"
            local show = (isAmmoObj and pickupESPEnabled.ammo) or (not isAmmoObj and pickupESPEnabled.hp)
            if not show then 
                d.text.Visible = false; d.box.Visible = false
                continue 
            end
            local rootPart = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
            if not rootPart then continue end
            local sp, onScreen = cam:WorldToViewportPoint(rootPart.Position)
            if not onScreen then 
                d.text.Visible = false; d.box.Visible = false
                continue 
            end
            local col = state.colors.box
            local bw, bh = 10, 10
            d.box.Size = Vector2.new(bw, bh)
            d.box.Position = Vector2.new(sp.X - bw/2, sp.Y - bh/2)
            d.box.Color = col
            d.box.Visible = true
            d.text.Position = Vector2.new(sp.X, sp.Y - 20)
            d.text.Color = col
            d.text.Visible = true
        end
    end
end)

connect(run.Heartbeat, function()
    if flags["killfeed_on"] then
        pcall(function()
            local feed = ws:FindFirstChild("KillFeed")
            if feed then
                for _, child in ipairs(feed:GetChildren()) do
                    if child:FindFirstChild("Assist") then child.Assist.Value = flags["killfeed_assist"] or "" end
                    if child:FindFirstChild("Killer") then child.Killer.Value = flags["killfeed_killer"] or "" end
                    if child:FindFirstChild("Victim") then child.Victim.Value = flags["killfeed_victim"] or "" end
                end
            end
        end)
    end
end)

connect(uis.JumpRequest, function()
    if flags["inf_jump"] then 
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end 
    end
end)

connect(lp.Idled, function()
    if flags["misc_anti_afk"] or flags["anti_afk"] then
        if VIM then 
            VIM:SendKeyEvent(true, Enum.KeyCode.ButtonB, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.ButtonB, false, game) 
        end
    end
end)

connect(lp.CharacterAdded, function(char)
    myOrigSizes = {} 
    local h = char:WaitForChild("Humanoid")
    task.wait(0.15)
    if flags["speed_on"] then apply_walkspeed(true, flags["walkspeed"] or 50) end
    if flags["jump_on"] then apply_jumppower(true, flags["jump_power"] or 50) end
    pcall(function() cam.FieldOfView = flags["cam_fov"] or defaultFOV end)
    pcall(function() lp.Settings.FOV.Value = flags["cam_fov"] or defaultFOV end)
    if flags["fly_on"] then h.PlatformStand = true end
    task.wait(0.5)
    if flags["chams_on"] then reapplyAllChams() end
    if flags["hitbox_on"] or flags["silent_aim"] then updateAllHitboxes() end
end)

connect(plrs.PlayerAdded, function(pl)
    connect(pl.CharacterAdded, function(char)
        task.wait(1)
        if flags["highlight_enemies"] and not char:FindFirstChild("LunarHL") then
            local hh = Instance.new("Highlight")
            hh.Name = "LunarHL"; hh.FillColor = state.colors.hlEnemy
            hh.OutlineColor = rgb(255, 255, 255); hh.FillTransparency = 0.5; hh.Parent = char
        end
        task.wait(0.5)
        if flags["chams_on"] then applyChams(pl) end
        if flags["hitbox_on"] or flags["silent_aim"] then expandHitbox(pl) end
    end)
    connect(pl.CharacterRemoving, function() hitboxOrigSizes[pl] = nil end)
end)

task.spawn(function()
    task.wait(1)
    if isfile(library.directory .. "/silentload.cfg") then
        window.set_menu_visibility(false)
        flags["silent_load"] = true
    end
    if isfile(library.directory .. "/autoexec.cfg") then
        flags["auto_exec_on_join"] = true
        if queue_on_teleport then
            queue_on_teleport(s_url)
        end
    end

    local autoLoadPath = library.directory .. "/autoload.cfg"
    if isfile(autoLoadPath) then
        local cfgName = readfile(autoLoadPath)
        if cfgName and cfgName ~= "" then
            local path = dir .. cfgName .. ".cfg"
            if isfile(path) then
                library:load_config(readfile(path))
                applyLoadedSkins()
                library:notification({text = "auto loaded: "..cfgName})
            end
        end
    end
end)

uiSec:slider({
    name = "Colorpicker Anim Speed",
    flag = "color_picker_anim_speed",
    min = 0,
    max = 5,
    default = 2,
    interval = 0.01
})

aimbotTab.open_tab()
