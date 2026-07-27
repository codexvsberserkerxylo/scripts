

if getgenv().library then
    if type(getgenv().library.unload) == "function" then
        pcall(function() getgenv().library:unload() end)
    elseif getgenv().library.gui then
        pcall(function() getgenv().library.gui:Destroy() end)
    end
    getgenv().library = nil
end
print("init")
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/i77lhm/vaderpaste/refs/heads/main/library.lua"))()
local flags = library.flags
library.directory = "LunarX-ot"

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

local lp = plrs.LocalPlayer
local cam = ws.CurrentCamera
local mouse = lp:GetMouse()

local WeaponManager = require(rs.Common.Managers.WeaponManager)
local WeaponPackets = require(rs.Common.Packets.WeaponPackets)
local ModelsManager = require(rs.Common.Managers.ModelsManager)
local MainGamePackets = require(rs.Common.Packets.MainGamePackets)
local WeaponClient = require(lp.PlayerScripts.Start.Game.WeaponClient)
local ViewmodelClient = require(lp.PlayerScripts.Start.Game.ViewmodelClient)
local ByteNetReliable = rs:WaitForChild('ByteNetReliable')

local function getChar() return lp.Character end
local function getHum() local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local _Weapons = WeaponManager.getWeapons()
for name, data in pairs(_Weapons) do
    data._firerate = data.firerate
    data._damage = data.damage
    data._reloadTime = data.reloadTime
    data._magazine = data.magazine
end

local origGetWeaponModel = ModelsManager.getWeaponModel
local origGetKnifeModel = ModelsManager.getKnifeModel
local origVMShoot = ViewmodelClient.shoot
local origScope = WeaponClient.scope

local box_color = rgb(100, 255, 255)
local tracer_color = rgb(100, 100, 255)
local skel_color = rgb(255, 100, 255)
local name_color = rgb(255, 255, 255)
local dist_color = rgb(180, 180, 180)
local chams_color = rgb(170, 85, 235)
local xhair_color = rgb(255, 255, 255)
local fov_color = rgb(100, 100, 255)
local hitTracerColor = rgb(255, 50, 50)
local aura_vis_color = rgb(255, 255, 0)
local danger_color = rgb(255, 0, 0)

local wpn_chams_color = rgb(255, 0, 0)
local wpn_chams_trans = 0
local arm_chams_color = rgb(0, 255, 0)
local arm_chams_trans = 0

local state = {
    aim_target_part = nil, 
    aim_target_player = nil,
    silent_target_part = nil,
    silent_target_player = nil,
    lastClickTime = 0
}

local keybinds = { aim = false, trigger = false }
local ws_enabled = false
local jp_enabled = false
local currTarget = nil
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
    local d, err = Drawing.new(t)
    if not d then return nil end
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    return d
end

local function applyWeaponMods()
    for name, data in pairs(_Weapons) do
        data.firerate = flags["no_shoot_delay"] and 9999 or data._firerate
        data.damage = data._damage
        data.reloadTime = flags["instant_reload"] and 0 or data._reloadTime
        data.magazine = flags["inf_ammo"] and 999 or data._magazine
    end
    WeaponManager.Constants.DEFAULT_FIRERATE = flags["no_shoot_delay"] and 9999 or 2
    WeaponManager.Constants.DEFAULT_PISTOL_FIRERATE = flags["no_shoot_delay"] and 9999 or 4
    WeaponManager.Constants.DEFAULT_DAMAGE = 100
    WeaponManager.Constants.DEFAULT_PISTOL_DAMAGE = 50
    WeaponManager.Constants.DEFAULT_RELOAD_TIME = flags["instant_reload"] and 0 or 0.75
    WeaponManager.Constants.DEFAULT_PISTOL_RELOAD_TIME = flags["instant_reload"] and 0 or 0.5
    WeaponManager.Constants.DEFAULT_MAGAZINE = flags["inf_ammo"] and 999 or 1
end

ModelsManager.getWeaponModel = function(name)
    if type(name) == "buffer" then name = tostring(name) end
    if type(name) ~= "string" then return origGetWeaponModel(name) end
    if flags["ot_weapon_skin"] ~= "" and flags["ot_weapon_skin"] ~= nil then
        local model = origGetWeaponModel(flags["ot_weapon_skin"])
        if model then return model end
    end
    return origGetWeaponModel(name)
end

ModelsManager.getKnifeModel = function(name)
    if type(name) == "buffer" then name = tostring(name) end
    if type(name) ~= "string" then return origGetKnifeModel(name) end
    if flags["ot_knife_skin"] ~= "" and flags["ot_knife_skin"] ~= nil then
        local model = origGetKnifeModel(flags["ot_knife_skin"])
        if model then return model end
    end
    return origGetKnifeModel(name)
end

local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if not checkcaller() then
        if key == "WalkSpeed" and ws_enabled and self:IsA("Humanoid") then return 16 end
        if key == "JumpPower" and jp_enabled and self:IsA("Humanoid") then return 50 end
    end
    return oldIndex(self, key)
end))

local old
old = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
    if getnamecallmethod() == 'FireServer' and self == ByteNetReliable and currTarget then
        local args = {...}

        if typeof(args[2]) == 'table' and typeof(args[2][1]) == 'Instance' then
            local hitchance = flags["silent_hitchance"] or 100
            if math.random(1, 100) <= hitchance then
                args[2][1] = currTarget
                args[2][2] = currTarget.Head
            end
        end
    end

    return old(self, ...)
end))

local function apply_walkspeed(state, speed)
    ws_enabled = state
    local hum = getHum()
    if hum then hum.WalkSpeed = state and (speed or 50) or 16 end
end

local function apply_jumppower(state, power)
    jp_enabled = state
    local hum = getHum()
    if hum then hum.JumpPower = state and (power or 50) or 50 end
end

local killAuraActive = false
local function runKillAura()
    while killAuraActive do
        local root = getRoot()
        if root then
            for _, char in ipairs(getTargets()) do
                local hum = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                if hum and head and hum.Health > 0 then
                    local dist = (head.Position - root.Position).Magnitude
                    if dist <= (flags["kill_aura_range"] or 50) then
                        currTarget = char
                        pcall(function() WeaponClient.fire() end)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end
local function setKillAura(active)
    killAuraActive = active
    if active then task.spawn(runKillAura) end
end

local hitboxParts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
local function expandHitbox(char)
    local sz = flags["hitbox_size"] or 8
    for _, name in ipairs(hitboxParts) do
        local part = char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            pcall(function() part.Size = Vector3.new(sz, sz, sz) end)
        end
    end
end

function getTargets()
    local targets = {}
    for _, plr in ipairs(plrs:GetPlayers()) do
        if plr ~= lp and plr.Character then
            table.insert(targets, plr.Character)
        end
    end
    for _, obj in ipairs(ws:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not plrs:GetPlayerFromCharacter(obj) then
            table.insert(targets, obj)
        end
    end
    return targets
end

local function getAimTarget()
    local mp = uis:GetMouseLocation()
    local fov = flags["aim_radius"] or 150
    local maxDist = flags["aim_max_dist"] or 500
    local root = getRoot()
    local best, bestScore = nil, math.huge

    for _, char in ipairs(getTargets()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(flags["aim_part"] or "Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (h and part and hrp and h.Health > 0) then continue end
        
        if root and (hrp.Position - root.Position).Magnitude > maxDist then continue end

        if flags["aim_wall_check"] then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {getChar(), char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = ws:Raycast(cam.CFrame.Position, (part.Position - cam.CFrame.Position), rp)
            if hit and not hit.Instance:IsDescendantOf(char) then continue end
        end

        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        
        local screenDist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
        if screenDist > fov then continue end

        if screenDist < bestScore then best = char; bestScore = screenDist end
    end
    return best
end

local function getSilentTarget()
    local mp = uis:GetMouseLocation()
    local fov = flags["silent_radius"] or 150
    local maxDist = flags["aim_max_dist"] or 500
    local root = getRoot()
    local best, bestScore = nil, math.huge

    for _, char in ipairs(getTargets()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local part = char:FindFirstChild(flags["aim_part"] or "Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (h and part and hrp and h.Health > 0) then continue end
        
        local dist3D = root and (hrp.Position - root.Position).Magnitude or 0
        if not flags["inf_distance"] and dist3D > maxDist then continue end

        if flags["silent_wall_check"] and not flags["wallbang"] then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {getChar(), char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = ws:Raycast(cam.CFrame.Position, (part.Position - cam.CFrame.Position), rp)
            if hit and not hit.Instance:IsDescendantOf(char) then continue end
        end

        local sp, onScreen = cam:WorldToViewportPoint(part.Position)
        if not flags["inf_distance"] and not onScreen then continue end
        
        local screenDist = onScreen and (Vector2.new(sp.X, sp.Y) - mp).Magnitude or math.huge
        if not flags["inf_distance"] and screenDist > fov then continue end

        local score = flags["inf_distance"] and dist3D or screenDist

        if score < bestScore then best = char; bestScore = score end
    end
    return best
end

local espObjects = {}
local hitTracers = {}
local dangerIndicators = {}
local skel_pairs = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"}
}
local skel_pairs_r6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function buildESP(char)
    if espObjects[char] then return end
    local corners = {}
    for i = 1, 8 do corners[i] = newDraw("Line", {Thickness = 2, Visible = false, Color = box_color}) end
    local skeleton = {}
    for i = 1, #skel_pairs do skeleton[i] = newDraw("Line", {Thickness = 1, Visible = false, Color = skel_color}) end
    
    espObjects[char] = {
        box = newDraw("Square", {Thickness = 1, Filled = false, Visible = false, Color = box_color}),
        corners = corners,
        skeleton = skeleton,
        nameText = newDraw("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = name_color, Font = 2}),
        distText = newDraw("Text", {Size = 11, Center = true, Outline = true, Visible = false, Color = dist_color, Font = 2}),
        hpBG = newDraw("Square", {Filled = true, Visible = false, Color = rgb(0, 0, 0)}),
        hpBar = newDraw("Square", {Filled = true, Visible = false, Color = rgb(0, 255, 0)}),
        tracer = newDraw("Line", {Thickness = 1, Visible = false, Color = tracer_color})
    }
end

local function destroyESP(char)
    local d = espObjects[char]
    if not d then return end
    for _, v in pairs(d.corners) do pcall(function() v:Remove() end) end
    for _, v in pairs(d.skeleton) do pcall(function() v:Remove() end) end
    for k, v in pairs(d) do
        if k ~= "corners" and k ~= "skeleton" then pcall(function() v:Remove() end) end
    end
    espObjects[char] = nil
end

local function applyChams(char)
    if not char or not char.Parent then return end
    if not flags["chams_on"] then
        if char:FindFirstChild("LunarCham") then char.LunarCham:Destroy() end
        return
    end
    
    if not char:FindFirstChild("LunarCham") then
        local h = Instance.new("Highlight")
        h.Name = "LunarCham"
        h.FillColor = chams_color
        h.OutlineColor = Color3.new(1, 1, 1)
        h.Parent = char
    end
    
    local c = char.LunarCham
    c.FillColor = chams_color
    c.FillTransparency = 0.5
    c.OutlineTransparency = 0
end

local function applyVMChams()
    local vm = cam:FindFirstChild("Viewmodel")
    if not vm then return end
    
    local function apply(part, color, material, trans, enabled)
        if not part or not part:IsA("BasePart") then return end
        if enabled then
            if not part:GetAttribute("LunarVMOrig") then
                part:SetAttribute("LunarVMOrig", true)
                part:SetAttribute("OrigMat", part.Material)
                part:SetAttribute("OrigColor", part.Color)
                part:SetAttribute("OrigTrans", part.Transparency)
            end
            part.Color = color
            part.Material = material
            part.Transparency = trans
        else
            if part:GetAttribute("LunarVMOrig") then
                part.Material = part:GetAttribute("OrigMat")
                part.Color = part:GetAttribute("OrigColor")
                part.Transparency = part:GetAttribute("OrigTrans")
                part:SetAttribute("LunarVMOrig", nil)
            end
        end
    end

    for _, child in ipairs(vm:GetChildren()) do
        if string.find(child.Name, "Arm") then
            apply(child, arm_chams_color, Enum.Material[flags["arm_chams_mat"] or "Neon"], arm_chams_trans, flags["arm_chams_on"])
            for _, desc in ipairs(child:GetDescendants()) do
                apply(desc, arm_chams_color, Enum.Material[flags["arm_chams_mat"] or "Neon"], arm_chams_trans, flags["arm_chams_on"])
            end
        elseif child.Name == "Weapon" then
            apply(child, wpn_chams_color, Enum.Material[flags["wpn_chams_mat"] or "Neon"], wpn_chams_trans, flags["wpn_chams_on"])
            for _, desc in ipairs(child:GetDescendants()) do
                apply(desc, wpn_chams_color, Enum.Material[flags["wpn_chams_mat"] or "Neon"], wpn_chams_trans, flags["wpn_chams_on"])
            end
        end
    end
end

local weaponSkins, knifeSkins = {}, {}
for k, v in pairs(WeaponManager.getWeapons()) do table.insert(weaponSkins, k) end
for k, v in pairs(WeaponManager.getKnives()) do table.insert(knifeSkins, k) end
table.sort(weaponSkins)
table.sort(knifeSkins)

local radarGui = Instance.new("ScreenGui")
radarGui.Name = "LunarRadar"
radarGui.Parent = game:GetService("CoreGui")
radarGui.Enabled = false

local radarFrame = Instance.new("Frame", radarGui)
radarFrame.Size = UDim2.new(0, 150, 0, 150)
radarFrame.Position = UDim2.new(0, 15, 0, 15)
radarFrame.BackgroundColor3 = Color3.new(0, 0, 0)
radarFrame.BackgroundTransparency = 0.5
radarFrame.BorderSizePixel = 0
Instance.new("UICorner", radarFrame).CornerRadius = UDim.new(1, 0)

local radarCenter = Instance.new("Frame", radarFrame)
radarCenter.Size = UDim2.new(0, 4, 0, 4)
radarCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
radarCenter.BackgroundColor3 = Color3.new(1, 1, 1)
radarCenter.BorderSizePixel = 0
Instance.new("UICorner", radarCenter).CornerRadius = UDim.new(1, 0)

local radarDots = {}
local radarDotColor = rgb(255, 0, 0) -- triple t

local auraPart = Instance.new("Part")
auraPart.Anchored = true
auraPart.CanCollide = false
auraPart.Transparency = 0.5
auraPart.Material = Enum.Material.Neon
auraPart.Size = Vector3.new(1, 1, 1)
auraPart.Parent = nil

local auraMesh = Instance.new("SpecialMesh", auraPart)
auraMesh.MeshType = Enum.MeshType.Brick

local function setAuraShape(shape)
    auraMesh.MeshId = ""
    if shape == "Circle" then
        auraMesh.MeshType = Enum.MeshType.Sphere
    elseif shape == "Cube" then
        auraMesh.MeshType = Enum.MeshType.Brick
    elseif shape == "Cylinder" then
        auraMesh.MeshType = Enum.MeshType.Cylinder
    elseif shape == "Diamond" then
        auraMesh.MeshType = Enum.MeshType.FileMesh
        auraMesh.MeshId = "rbxassetid://9756362"
    end
end

local window = library:window({ name = "lunar x | one tap", size = UDim2.fromOffset(580, 600) })

local aimbotTab = window:tab({ name = "aimbot" })
local visualsTab = window:tab({ name = "visuals" })
local weaponTab = window:tab({ name = "weapon" })
local skinsTab = window:tab({ name = "skins" })
local miscTab = window:tab({ name = "misc" })
local settingsTab = window:tab({ name = "settings" })

local aimbotSec = aimbotTab:section({ name = "aimbot", side = "left" })
local silentSec = aimbotTab:section({ name = "silent aim", side = "left" })
local aimCfg = aimbotTab:section({ name = "config", side = "left" })
local fovSec = aimbotTab:section({ name = "fov circle", side = "right" })
local auraSec = aimbotTab:section({ name = "aura", side = "right" })

aimbotSec:toggle({ name = "Aimbot", flag = "aim_on", default = false })
aimbotSec:keybind({ name = "Aimbot Bind", flag = "aim_key", default = Enum.KeyCode.E, mode = "hold", callback = function(v) keybinds.aim = v end })
aimbotSec:toggle({ name = "Wall Check", flag = "aim_wall_check", default = true })
aimbotSec:toggle({ name = "Trigger Bot", flag = "triggerbot", default = false })
aimbotSec:keybind({ name = "Trigger Bind", flag = "trigger_key", default = Enum.KeyCode.Q, mode = "hold", callback = function(v) keybinds.trigger = v end })
aimbotSec:toggle({ name = "Auto Shoot", flag = "auto_shoott", default = false })
aimbotSec:slider({ name = "Auto Shoot Delay", flag = "auto_shoot_delay", min = 0.01, max = 1, default = 0.05, interval = 0.01, suffix = "s" })

silentSec:toggle({ name = "Silent Aim", flag = "silent_aim", default = false })
silentSec:slider({ name = "Hit Chance", flag = "silent_hitchance", min = 1, max = 100, default = 100, interval = 1, suffix = "%" })
silentSec:toggle({ name = "Wall Check", flag = "silent_wall_check", default = true })
silentSec:toggle({ name = "Wallbang", flag = "wallbang", default = false })
silentSec:toggle({ name = "Inf Distance", flag = "inf_distance", default = false })
silentSec:slider({ name = "Silent Aim Radius", flag = "silent_radius", min = 10, max = 1000, default = 150, interval = 5, suffix = "px" })

aimCfg:dropdown({ name = "Target Part", flag = "aim_part", items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, default = "Head" })
aimCfg:slider({ name = "Smoothness", flag = "aim_smooth", min = 0.01, max = 1, default = 0.15, interval = 0.01, suffix = "x" })
aimCfg:slider({ name = "Max Distance", flag = "aim_max_dist", min = 50, max = 5000, default = 1000, interval = 50, suffix = " st" })

local fovCircle = newDraw("Circle", { Thickness = 1, Filled = false, Visible = false, Color = fov_color, Radius = 150 })
fovSec:toggle({ name = "Visible", flag = "fov_visible", default = false, callback = function(v) if fovCircle then fovCircle.Visible = v end end })
fovSec:colorpicker({ name = "FOV Color", flag = "fov_color", color = fov_color, alpha = 0, callback = function(c, t)
    fov_color = c
    if fovCircle then fovCircle.Color = c end
end})
fovSec:slider({ name = "Radius", flag = "aim_radius", min = 10, max = 1000, default = 150, interval = 5, suffix = "px", callback = function(v) if fovCircle then fovCircle.Radius = v end end })

auraSec:toggle({ name = "Kill Aura", flag = "kill_aura", default = false, callback = setKillAura })
auraSec:slider({ name = "Kill Aura Range", flag = "kill_aura_range", min = 10, max = 500, default = 50, interval = 10, suffix = " st" })
auraSec:toggle({ name = "Hitbox Expander", flag = "hitbox_on", default = false })
auraSec:slider({ name = "Hitbox Size", flag = "hitbox_size", min = 1, max = 60, default = 8, interval = 0.5, suffix = " st" })

local espSec = visualsTab:section({ name = "player esp", side = "left" })
local tracerSec = visualsTab:section({ name = "tracer config", side = "left" })
local chamsSec = visualsTab:section({ name = "chams", side = "left" })
local fxSec = visualsTab:section({ name = "effects", side = "left" })
local envSec = visualsTab:section({ name = "environment", side = "right" })
local xhairSec = visualsTab:section({ name = "custom crosshair", side = "right" })
local vmChamsSec = visualsTab:section({ name = "viewmodel chams", side = "right" })

local materials = {"Neon", "ForceField", "Glass", "Ice", "Plastic", "Metal", "SmoothPlastic"}

vmChamsSec:toggle({ name = "Weapon Chams", flag = "wpn_chams_on", default = false })
vmChamsSec:colorpicker({ name = "Color", flag = "wpn_chams_color", color = wpn_chams_color, alpha = 0, callback = function(c, t)
    wpn_chams_color = c
end})
vmChamsSec:dropdown({ name = "Material", flag = "wpn_chams_mat", items = materials, default = "Neon" })
vmChamsSec:slider({ name = "Transparency", flag = "wpn_chams_trans", min = 0, max = 1, default = 0, interval = 0.1, callback = function(v) wpn_chams_trans = v end })

vmChamsSec:toggle({ name = "Arm Chams", flag = "arm_chams_on", default = false })
vmChamsSec:colorpicker({ name = "Color", flag = "arm_chams_color", color = arm_chams_color, alpha = 0, callback = function(c, t)
    arm_chams_color = c
end})
vmChamsSec:dropdown({ name = "Material", flag = "arm_chams_mat", items = materials, default = "Neon" })
vmChamsSec:slider({ name = "Transparency", flag = "arm_chams_trans", min = 0, max = 1, default = 0, interval = 0.1, callback = function(v) arm_chams_trans = v end })

espSec:toggle({ name = "ESP Enabled", flag = "esp_on", default = false })
espSec:slider({ name = "Max Distance", flag = "esp_max_dist", min = 50, max = 5000, default = 2000, interval = 50, suffix = " st" })
espSec:dropdown({ name = "Box Style", flag = "box_style", items = {"None", "Full Box", "Corner Box"}, default = "Corner Box" })
espSec:toggle({ name = "Box ESP", flag = "box_esp", default = true })
espSec:colorpicker({ name = "Box Color", flag = "box_color", color = box_color, alpha = 0, callback = function(c) box_color = c end })
espSec:toggle({ name = "Name ESP", flag = "name_esp", default = false })
espSec:toggle({ name = "Distance ESP", flag = "dist_esp", default = false })
espSec:toggle({ name = "Health Bar", flag = "hp_esp", default = false })
espSec:toggle({ name = "Skeleton ESP", flag = "skel_esp", default = false })
espSec:colorpicker({ name = "Skeleton Color", flag = "skel_color", color = skel_color, alpha = 0, callback = function(c) skel_color = c end })

tracerSec:toggle({ name = "Tracers", flag = "tracers_on", default = false })
tracerSec:colorpicker({ name = "Tracer Color", flag = "tracer_color", color = tracer_color, alpha = 0, callback = function(c) tracer_color = c end })
tracerSec:slider({ name = "Thickness", flag = "tracer_thick", min = 1, max = 5, default = 1, interval = 1, suffix = "px" })
tracerSec:dropdown({ name = "Origin", flag = "tracer_origin", items = {"Mouse", "HRP", "Arms"}, default = "Mouse" })
tracerSec:dropdown({ name = "Destination", flag = "tracer_dest", items = {"Head", "HRP", "Torso"}, default = "Head" })

chamsSec:toggle({ name = "Chams", flag = "chams_on", default = false })
chamsSec:colorpicker({ name = "Chams Color", flag = "chams_color", color = chams_color, alpha = 0, callback = function(c) chams_color = c end })

fxSec:toggle({ name = "Kill Aura Visualizer", flag = "aura_vis", default = false })
fxSec:dropdown({ name = "Aura Shape", flag = "aura_vis_shape", items = {"Circle", "Cube", "Cylinder", "Diamond"}, default = "Cylinder", callback = function(v) setAuraShape(v) end })
fxSec:colorpicker({ name = "Aura Vis Color", flag = "aura_vis_color", color = aura_vis_color, alpha = 0, callback = function(c) aura_vis_color = c end })
fxSec:slider({ name = "Aura Transparency", flag = "aura_vis_trans", min = 0, max = 1, default = 0.5, interval = 0.1 })
fxSec:dropdown({ name = "Aura Material", flag = "aura_vis_mat", items = materials, default = "Neon" })
fxSec:dropdown({ name = "Aura Position", flag = "aura_vis_pos", items = {"Head", "HumanoidRootPart", "LeftUpperLeg", "RightUpperLeg"}, default = "HumanoidRootPart" })
fxSec:slider({ name = "Aura X Offset", flag = "aura_vis_x", min = -10, max = 10, default = 0, interval = 0.5 })
fxSec:slider({ name = "Aura Y Offset", flag = "aura_vis_y", min = -10, max = 10, default = 0, interval = 0.5 })
fxSec:slider({ name = "Aura Thickness", flag = "aura_vis_thick", min = 0.1, max = 10, default = 0.1, interval = 0.1 })

fxSec:toggle({ name = "Danger Indicators", flag = "danger_indicators", default = false })
fxSec:colorpicker({ name = "Danger Color", flag = "danger_color", color = danger_color, alpha = 0, callback = function(c) danger_color = c end })

local atmosphere = light:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "LunarAtmosphere"
atmosphere.Parent = light

local function getCC()
    local cc = light:FindFirstChild("LunarCC")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "LunarCC"
        cc.Parent = light
    end
    return cc
end

envSec:dropdown({ name = "Skybox Preset", flag = "skybox_preset", items = {"default", "space", "nebula", "sword fight", "checker", "67", "larp", "astolfo", "rin tohsaka", "black and white", "sinister", "nick was here", "israel", "tung tung tung sahur", "lore accurate rayquaza", "my goat", "volt", "custom"}, default = "default", callback = function(v)
    for _, obj in pairs(game.Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end

    if v == "default" then
        return
    end

    local id = "0"
    if v == "space" then id = "2677508605"
    elseif v == "nebula" then id = "11992958367"
    elseif v == "sword fight" then id = "138569010610226"
    elseif v == "checker" then id = "2424906060"
	elseif v == "67" then id = "123574199714471"
	elseif v == "larp" then id = "92504539826208"
	elseif v == "astolfo" then id = "17871757372"
	elseif v == "rin tohsaka" then id = "18726861143"
    elseif v == "black and white" then id = "11526322514"
    elseif v == "sinister" then id = "80534607281301"
    elseif v == "nick was here" then id = "139071281654202"
    elseif v == "israel" then id = "10012831703"
    elseif v == "tung tung tung sahur" then id = "76287583641908"
    elseif v == "lore accurate rayquaza" then id = "4899954361"
    elseif v == "my goat" then id = "139932718825873"
    elseif v == "volt" then id = "120346696354096"
    elseif v == "custom" then id = tostring(flags["skybox_id"] or "0") end

    local sky = Instance.new("Sky")
    sky.Name = "Sky"
    sky.SkyboxBk = "rbxassetid://"..id
    sky.SkyboxDn = "rbxassetid://"..id
    sky.SkyboxFt = "rbxassetid://"..id
    sky.SkyboxLf = "rbxassetid://"..id
    sky.SkyboxRt = "rbxassetid://"..id
    sky.SkyboxUp = "rbxassetid://"..id
    sky.Parent = game.Lighting
end})

envSec:textbox({ name = "Custom Skybox ID", flag = "skybox_id", placeholder = "ID", callback = function() 
    if flags["skybox_preset"] == "custom" then 
        local p = flags["skybox_preset"]
        flags["skybox_preset"] = "default"
        flags["skybox_preset"] = p 
    end 
end})
envSec:slider({ name = "Brightness", flag = "env_brightness", min = 0, max = 5, default = 2, interval = 0.1, callback = function(v) light.Brightness = v end })
envSec:slider({ name = "Time of Day", flag = "env_time", min = 0, max = 24, default = 12, interval = 0.5, callback = function(v) light.ClockTime = v end })
envSec:slider({ name = "Fog End", flag = "env_fogend", min = 0, max = 100000, default = 100000, interval = 1000, callback = function(v) light.FogEnd = v end })
envSec:slider({ name = "Fog Start", flag = "env_fogstart", min = 0, max = 100000, default = 0, interval = 1000, callback = function(v) light.FogStart = v end })
envSec:colorpicker({ name = "Fog Color", flag = "fog_color", color = rgb(128, 128, 128), alpha = 0, callback = function(c) light.FogColor = c end })
envSec:slider({ name = "Atmosphere Density", flag = "atm_density", min = 0, max = 1, default = 0.3, interval = 0.01, callback = function(v) atmosphere.Density = v end })
envSec:slider({ name = "Atmosphere Glare", flag = "atm_glare", min = 0, max = 1, default = 0, interval = 0.01, callback = function(v) atmosphere.Glare = v end })
envSec:slider({ name = "Atmosphere Haze", flag = "atm_haze", min = 0, max = 1, default = 0, interval = 0.01, callback = function(v) atmosphere.Haze = v end })
envSec:colorpicker({ name = "Atmosphere Color", flag = "atm_color", color = rgb(199, 170, 107), alpha = 0, callback = function(c) atmosphere.Color = c end })
envSec:colorpicker({ name = "Atmosphere Decay", flag = "atm_decay", color = rgb(106, 112, 125), alpha = 0, callback = function(c) atmosphere.Decay = c end })

envSec:slider({ name = "Saturation", flag = "saturation", min = -1, max = 1, default = 0, interval = 0.01, callback = function(v) getCC().Saturation = v end })
envSec:slider({ name = "Brightness CC", flag = "cc_bright", min = -1, max = 1, default = 0, interval = 0.01, callback = function(v) getCC().Brightness = v end })
envSec:slider({ name = "Contrast CC", flag = "cc_contrast", min = -1, max = 1, default = 0, interval = 0.01, callback = function(v) getCC().Contrast = v end })
envSec:colorpicker({ name = "CC Tint", flag = "cc_tint", color = rgb(255, 255, 255), alpha = 0, callback = function(c) getCC().TintColor = c end })

local xhairLines = {
    top = newDraw("Line", {Thickness = 2, Visible = false, Color = xhair_color}),
    bottom = newDraw("Line", {Thickness = 2, Visible = false, Color = xhair_color}),
    left = newDraw("Line", {Thickness = 2, Visible = false, Color = xhair_color}),
    right = newDraw("Line", {Thickness = 2, Visible = false, Color = xhair_color}),
    dot = newDraw("Circle", {Radius = 2, Filled = true, Visible = false, Color = xhair_color})
}
xhairSec:toggle({ name = "Crosshair", flag = "xhair_on", default = false, callback = function(v) if not v then for _, l in pairs(xhairLines) do if l then l.Visible = false end end end end })
xhairSec:slider({ name = "Size", flag = "xhair_size", min = 2, max = 30, default = 10, interval = 1, suffix = "px" })
xhairSec:slider({ name = "Gap", flag = "xhair_gap", min = 0, max = 15, default = 3, interval = 1, suffix = "px" })
xhairSec:toggle({ name = "Center Dot", flag = "xhair_dot", default = true })
xhairSec:colorpicker({ name = "Color", flag = "xhair_color", color = xhair_color, alpha = 0, callback = function(c) xhair_color = c; for _, l in pairs(xhairLines) do if l then l.Color = c end end end })

local xphooked = false

local function hookmaxxp()
    if xphooked then return end
    
    if WeaponPackets.useWeapon and WeaponPackets.useWeapon.send then
        local origsendd = WeaponPackets.useWeapon.send
        WeaponPackets.useWeapon.send = function(data)
            if flags["max_xp"] then
                data.was360 = true
                data.quickscope = true
            end
            return origsendd(data)
        end
        xphooked = true
        return
    end

    local firefunc = WeaponClient.fire
    if not firefunc then return end
    
    local success, u26 = pcall(debug.getupvalue, firefunc, 1)
    if not success or type(u26) ~= "function" then return end
    
    for i = 1, 30 do
        local ok, val = pcall(debug.getupvalue, u26, i)
        if not ok then break end
        if type(val) == "table" and type(val.send) == "function" and type(val.listen) == "function" then
            local origss = val.send
            val.send = function(data)
                if flags["max_xp"] then
                    data.was360 = true
                    data.quickscope = true
					data.midair = true
                end
                return origss(data)
            end
            xphooked = true
            break
        end
    end
end

hookmaxxp()

local origvalues = WeaponClient.__setValues
WeaponClient.__setValues = function(self, key)
    local res = origvalues(self, key)
    hookmaxxp()
    return res
end

local weaponMainSec = weaponTab:section({ name = "weapon mods", side = "left" })
weaponMainSec:toggle({ name = "Inf Fire Rate", flag = "no_shoot_delay", default = false, callback = applyWeaponMods })
weaponMainSec:toggle({ name = "No Recoil", flag = "no_recoil", default = false, callback = function(v)
    if v then
        ViewmodelClient.shoot = function(...) end
    else
        ViewmodelClient.shoot = origVMShoot
    end
end})
weaponMainSec:toggle({ name = "Instant Reload", flag = "instant_reload", default = false, callback = applyWeaponMods })
weaponMainSec:toggle({ name = "Infinite Ammo", flag = "inf_ammo", default = false, callback = applyWeaponMods })
weaponMainSec:toggle({ name = "Max XP", flag = "max_xp", default = false })

local weaponSkinSec = skinsTab:section({ name = "weapons", side = "left" })
local weaponDrop = weaponSkinSec:dropdown({ name = "Select Weapon Skin", flag = "ot_weapon_skin", items = weaponSkins, default = "" })
weaponSkinSec:textbox({ flag = "search_weapon", placeholder = "search...", callback = function(text)
    local filtered = {}
    for _, item in ipairs(weaponSkins) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end
    weaponDrop:refresh_options(filtered)
end })
weaponSkinSec:button({ name = "apply", callback = function()
    library:notification({text = "applied: "..flags["ot_weapon_skin"]})
end})

local knifeSkinSec = skinsTab:section({ name = "knife", side = "right" })
local knifeDrop = knifeSkinSec:dropdown({ name = "Select Knife Skin", flag = "ot_knife_skin", items = knifeSkins, default = "" })
knifeSkinSec:textbox({ flag = "search_knife", placeholder = "search...", callback = function(text)
    local filtered = {}
    for _, item in ipairs(knifeSkins) do if string.find(string.lower(item), string.lower(text)) then table.insert(filtered, item) end end
    knifeDrop:refresh_options(filtered)
end })
knifeSkinSec:button({ name = "apply", callback = function()
    library:notification({text = "applied: "..flags["ot_knife_skin"]})
end})

local miscSec = miscTab:section({ name = "local player", side = "left" })
local moveSec = miscTab:section({ name = "movement", side = "left" })
local radarSec = miscTab:section({ name = "radar", side = "left" })
local serverSec = miscTab:section({ name = "server", side = "right" })

miscSec:toggle({ name = "Anti-AFK", flag = "anti_afk", default = false })
miscSec:toggle({ name = "Noclip", flag = "noclip_on", default = false })
miscSec:toggle({ name = "Auto Deploy", flag = "auto_deploy", default = false, callback = function(v)
    if v then
		while v do 
			MainGamePackets.deploy.send()
			task.wait(1)
		end
	end
end})
miscSec:toggle({ name = "Auto Respawn", flag = "auto_respawn", default = false, callback = function(v)
    if v then
        task.spawn(function()
            while flags["auto_respawn"] do
                local c = lp.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h and h.Health <= 0 then
                    pcall(function() MainGamePackets.respawn.send(true) end)
                end
                task.wait(1.5) -- dont change this or else it will bug out np
            end
        end)
    end
end})
miscSec:toggle({ name = "Auto Equip Weapon", flag = "auto_equip", default = false })
miscSec:dropdown({ name = "Equip Weapon", flag = "auto_equip_weapon", items = {"Primary", "Secondary", "Knife"}, default = "Primary" })
local tpConn
miscSec:toggle({ name = "Third Person", flag = "third_person", default = false, callback = function(v)
    if v then
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = 128
        WeaponClient.scope = function(...) end
        tpConn = lp:GetPropertyChangedSignal("CameraMode"):Connect(function()
            if lp.CameraMode ~= Enum.CameraMode.Classic then
                lp.CameraMode = Enum.CameraMode.Classic
            end
        end)
    else
        if tpConn then tpConn:Disconnect() tpConn = nil end
    end
end})
miscSec:toggle({ name = "Spin Bot", flag = "spin_on", default = false })
miscSec:slider({ name = "Spin Speed", flag = "spin_speed", min = 10, max = 10000, default = 180, interval = 10, suffix = " deg/s" })
moveSec:toggle({ name = "Speed Hack", flag = "speed_on", default = false, callback = function(v) apply_walkspeed(v, flags["walkspeed"] or 50) end })
moveSec:dropdown({ name = "Speed Method", flag = "speed_method", items = {"WalkSpeed", "CFrame", "Velocity"}, default = "WalkSpeed" })
moveSec:slider({ name = "WalkSpeed", flag = "walkspeed", min = 16, max = 500, default = 50, interval = 1, suffix = " ws" })
moveSec:toggle({ name = "Jump Hack", flag = "jump_on", default = false, callback = function(v) apply_jumppower(v, flags["jump_power"] or 50) end })
moveSec:dropdown({ name = "Jump Method", flag = "jump_method", items = {"JumpPower", "Velocity"}, default = "JumpPower" })
moveSec:slider({ name = "JumpPower", flag = "jump_power", min = 50, max = 500, default = 50, interval = 1, suffix = " jp" })

radarSec:toggle({ name = "Player Radar", flag = "radar_on", default = false, callback = function(v) radarGui.Enabled = v end })
radarSec:slider({ name = "Radar Size", flag = "radar_size", min = 50, max = 500, default = 150, interval = 10, callback = function(v) radarFrame.Size = UDim2.new(0, v, 0, v) end })
radarSec:slider({ name = "Radar Range", flag = "radar_range", min = 100, max = 2000, default = 500, interval = 50, suffix = " st" })
radarSec:slider({ name = "Radar X", flag = "radar_x", min = 0, max = 1920, default = 15, interval = 1, callback = function(v) radarFrame.Position = UDim2.new(0, v, 0, flags["radar_y"] or 15) end })
radarSec:slider({ name = "Radar Y", flag = "radar_y", min = 0, max = 1080, default = 15, interval = 1, callback = function(v) radarFrame.Position = UDim2.new(0, flags["radar_x"] or 15, 0, v) end })
radarSec:colorpicker({ name = "Radar Color", flag = "radar_color", color = radarDotColor, alpha = 0, callback = function(c) radarDotColor = c end })

serverSec:button({ name = "Copy j*b ID", callback = function() pcall(function() setclipboard(game.JobId) end) end })
serverSec:textbox({ name = "j*b ID", flag = "j*b_id_input", placeholder = "Enter j*b Id" })
serverSec:button({ name = "Join Server", callback = function()
    local id = flags["j*b_id_input"]
    if id and id ~= "" then
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, id, lp)
        end)
    else
        library:notification({text = "pls enter a valid j*b Id"})
    end
end })
serverSec:button({ name = "Server hop", callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, lp) end })

local cfgSec = settingsTab:section({ name = "configs", side = "left" })
local uiSec = settingsTab:section({ name = "ui", side = "right" })

local dir = library.directory .. "/configs/"
if not isfolder(library.directory) then makefolder(library.directory) end
if not isfolder(dir) then makefolder(dir) end
library.config_holder = cfgSec:dropdown({ name = "Configs", flag = "config_name_list", items = {}, default = "" })
cfgSec:textbox({ name = "Config Name", flag = "config_name_text_box", placeholder = "config name" })

cfgSec:button({ name = "Create", callback = function() local name = flags["config_name_text_box"]; if name and name ~= "" then writefile(dir .. name .. ".cfg", library:get_config()); library:config_list_update() end end })
cfgSec:button({ name = "Load", callback = function() local name = flags["config_name_list"]; if name and name ~= "" and isfile(dir .. name .. ".cfg") then library:load_config(readfile(dir .. name .. ".cfg")); library:notification({text = "Loaded config: "..name}) end end })
cfgSec:button({ name = "Save", callback = function() local name = flags["config_name_list"] or flags["config_name_text_box"]; if name and name ~= "" then writefile(dir .. name .. ".cfg", library:get_config()); library:config_list_update(); library:notification({text = "Saved config: "..name}) end end })
cfgSec:button({ name = "Delete", callback = function() local name = flags["config_name_list"]; if name and name ~= "" and isfile(dir .. name .. ".cfg") then delfile(dir .. name .. ".cfg"); library:config_list_update() end end })
cfgSec:button({ name = "Set Auto Load", callback = function() 
    local name = flags["config_name_list"]
    if name and name ~= "" then
        writefile(library.directory .. "/autoload.cfg", name)
        library:notification({text = "Set autoload to: "..name})
    else
        library:notification({text = "Select a config first"})
    end
end })

cfgSec:button({ name = "Stop Auto Load", callback = function()
    local p = library.directory .. "/autoload.cfg"
    if isfile(p) then
        delfile(p)
        library:notification({text = "Stopped auto loading"})
    else
        library:notification({text = "No autoload set"})
    end
end })
library:config_list_update()

uiSec:toggle({ name = "Keybind List", flag = "ui_keybind_list", default = false, callback = function(v) window.toggle_list(v) end })
uiSec:toggle({ name = "Player List", flag = "ui_player_list", default = false, callback = function(v) window.toggle_playerlist(v) end })
uiSec:keybind({ name = "Menu Toggle", flag = "menu_key", default = Enum.KeyCode.RightControl, callback = function(v) window.set_menu_visibility(v) end })
uiSec:colorpicker({ name = "Accent Color", flag = "accent_color", color = rgb(100, 100, 255), alpha = 0, callback = function(c) library:update_theme("accent", c) end })

local function safe_unload()
    if library and type(library.unload) == "function" then library:unload()
    else if library and library.gui then library.gui:Destroy() end; getgenv().library = nil end
end

uiSec:button({ name = "Unload", callback = function()
    disconnect_all()
    for char, _ in pairs(espObjects) do destroyESP(char) end
    if fovCircle then fovCircle:Remove() end
    for _, l in pairs(xhairLines) do if l then l:Remove() end end
    for _, t in ipairs(hitTracers) do if t.tracer then t.tracer:Remove() end end
    radarGui:Destroy()
    auraPart:Destroy()
    
    hookmetamethod(game, "__namecall", old)
    hookmetamethod(game, "__index", oldIndex)
    
    ModelsManager.getWeaponModel = origGetWeaponModel
    ModelsManager.getKnifeModel = origGetKnifeModel
    ViewmodelClient.shoot = origVMShoot
    WeaponClient.scope = origScope
    TableManager.lazyLoadModule = origLazyLoad
    
    applyWeaponMods()
    flags["no_shoot_delay"] = false
    flags["instant_reload"] = false
    flags["inf_ammo"] = false
    applyWeaponMods()

    safe_unload()
end})

local isFiring = false
connect(uis.InputBegan, function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gpe then
        isFiring = true
        state.lastClickTime = tick()
        task.spawn(function()
            while isFiring do
                if not uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then break end
                if flags["auto_fire"] then
                    VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, true, game, 0)
                    task.wait(0.02)
                    VIM:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, false, game, 0)
                    task.wait(0.05)
                else
                    task.wait(0.1)
                end
            end
        end)
    end
end)
connect(uis.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then isFiring = false end
end)

connect(run.Heartbeat, function(dt)
    local hum = getHum()
    if hum then
        if ws_enabled then
            local method = flags["speed_method"] or "WalkSpeed"
            local speedVal = flags["walkspeed"] or 50
            local isWalking = hum.MoveDirection.Magnitude > 0
            if isWalking then
                if method == "WalkSpeed" then
                    if hum.WalkSpeed ~= speedVal then hum.WalkSpeed = speedVal end
                elseif method == "CFrame" then
                    local root = getRoot()
                    if root then
                        root.CFrame = root.CFrame + (hum.MoveDirection * speedVal * dt)
                    end
                elseif method == "Velocity" then
                    local root = getRoot()
                    if root then
                        local vel = hum.MoveDirection * speedVal
                        root.AssemblyLinearVelocity = Vector3.new(vel.X, root.AssemblyLinearVelocity.Y, vel.Z)
                    end
                end
            else
                if method == "WalkSpeed" then
                    if hum.WalkSpeed ~= 16 then hum.WalkSpeed = 16 end
                elseif method == "Velocity" then
                    local root = getRoot()
                    if root then
                        root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
                    end
                end
            end
        end
        if jp_enabled then
            local method = flags["jump_method"] or "JumpPower"
            local jumpVal = flags["jump_power"] or 50
            if method == "JumpPower" then
                if hum.JumpPower ~= jumpVal then hum.JumpPower = jumpVal end
            elseif method == "Velocity" then
                local root = getRoot()
                if root and hum:GetState() == Enum.HumanoidStateType.Jumping then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jumpVal, root.AssemblyLinearVelocity.Z)
                end
            end
        end
    end
end)

connect(run.Stepped, function()
    if flags["noclip_on"] then
        local char = getChar()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

connect(run.Heartbeat, function()
    if flags["no_shoot_delay"] then
        pcall(function() WeaponClient.resetBullets(true) end)
    end
end)

local triggerCooldown = 0
local autoShootCooldown = 0
connect(run.RenderStepped, function(dt)
    local mp = uis:GetMouseLocation()
    local vp = cam.ViewportSize
    local espOn = flags["esp_on"]
    local rootPos = getRoot() and getRoot().Position

    local currentAimTarget = getAimTarget()
    state.aim_target_player = currentAimTarget
    state.aim_target_part = currentAimTarget and currentAimTarget:FindFirstChild(flags["aim_part"] or "Head") or nil

    if flags["silent_aim"] or flags["wallbang"] then
        currTarget = getSilentTarget()
    else
        currTarget = nil
    end

    applyVMChams()

    if flags["aim_on"] and keybinds.aim and state.aim_target_part then
        local smooth = flags["aim_smooth"] or 0.15
        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, state.aim_target_part.Position), smooth)
    end

    if flags["triggerbot"] and keybinds.trigger and state.aim_target_player and tick() - triggerCooldown > 0.1 then
        mouse1press(); task.wait(0.02); mouse1release(); triggerCooldown = tick()
    end

    if flags["auto_shoott"] and tick() - autoShootCooldown > (flags["auto_shoot_delay"] or 0.05) then
        pcall(function() WeaponClient.fire() end)
        autoShootCooldown = tick()
    end

    if flags["fov_visible"] and fovCircle then
        fovCircle.Visible = true
        fovCircle.Position = Vector2.new(mp.X, mp.Y)
        fovCircle.Color = fov_color
        fovCircle.Thickness = 1
        fovCircle.Radius = flags["aim_radius"] or 150
    else
        if fovCircle then fovCircle.Visible = false end
    end

    if flags["xhair_on"] then
        local cx, cy = vp.X / 2, vp.Y / 2
        local sz, gap, thk = flags["xhair_size"] or 10, flags["xhair_gap"] or 3, 2
        local col = xhair_color
        local function setL(l, fx, fy, tx, ty) 
            if not l then return end
            l.From, l.To = Vector2.new(fx, fy), Vector2.new(tx, ty)
            l.Thickness, l.Color, l.Visible = thk, col, true 
        end
        setL(xhairLines.top, cx, cy - gap - sz, cx, cy - gap)
        setL(xhairLines.bottom, cx, cy + gap, cx, cy + gap + sz)
        setL(xhairLines.left, cx - gap - sz, cy, cx - gap, cy)
        setL(xhairLines.right, cx + gap, cy, cx + gap + sz, cy)
        if xhairLines.dot then
            xhairLines.dot.Visible = flags["xhair_dot"] == true
            xhairLines.dot.Position = Vector2.new(cx, cy)
            xhairLines.dot.Color = col
        end
    else
        for _, l in pairs(xhairLines) do if l then l.Visible = false end end
    end

    if flags["spin_on"] then
        local r = getRoot()
        if r then
            r.CFrame = r.CFrame * CFrame.Angles(0, math.rad((flags["spin_speed"] or 180) * dt), 0)
        end
    end

    for i = #hitTracers, 1, -1 do
        local t = hitTracers[i]
        local age = tick() - t.time
        if age > (flags["tracer_fade"] or 2) then
            if t.tracer then t.tracer:Remove() end
            table.remove(hitTracers, i)
        else
            if t.tracer then t.tracer.Transparency = age / (flags["tracer_fade"] or 2) end
        end
    end

    if flags["danger_indicators"] and rootPos then
        for _, char in ipairs(getTargets()) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then
                local dirToTarget = (hrp.Position - rootPos)
                local dist = dirToTarget.Magnitude
                if dist < 300 then
                    local relPos = cam.CFrame:VectorToObjectSpace(dirToTarget)
                    if relPos.Z < 0 then
                        local angle = math.atan2(relPos.X, -relPos.Y)
                        local radius = 200
                        local ex = vp.X/2 + math.cos(angle) * radius
                        local ey = vp.Y/2 + math.sin(angle) * radius
                        
                        if not dangerIndicators[char] then
                            dangerIndicators[char] = newDraw("Text", {Size = 13, Center = true, Outline = true, Visible = false, Color = danger_color, Font = 2})
                        end
                        dangerIndicators[char].Text = "!\n"..math.floor(dist).."m"
                        dangerIndicators[char].Position = Vector2.new(ex, ey)
                        dangerIndicators[char].Color = danger_color
                        dangerIndicators[char].Visible = true
                    else
                        if dangerIndicators[char] then dangerIndicators[char].Visible = false end
                    end
                else
                    if dangerIndicators[char] then dangerIndicators[char].Visible = false end
                end
            else
                if dangerIndicators[char] then dangerIndicators[char]:Remove(); dangerIndicators[char] = nil end
            end
        end
    else
        for char, d in pairs(dangerIndicators) do d:Remove() end
        dangerIndicators = {}
    end

    if flags["aura_vis"] and killAuraActive then
        local char = getChar()
        if char then
            local p = char:FindFirstChild(flags["aura_vis_pos"] or "HumanoidRootPart")
            if p then
                auraPart.Color = aura_vis_color
                auraPart.Transparency = flags["aura_vis_trans"] or 0.5
                auraPart.Material = Enum.Material[flags["aura_vis_mat"] or "Neon"]
                
                local range = flags["kill_aura_range"] or 50
                local thick = flags["aura_vis_thick"] or 0.1
                local offset = Vector3.new(flags["aura_vis_x"] or 0, flags["aura_vis_y"] or 0, 0)
                local curShape = flags["aura_vis_shape"] or "Circle"
                
                if curShape == "Cylinder" then
                    auraMesh.Scale = Vector3.new(thick, range*2, range*2)
                    auraPart.CFrame = CFrame.new(p.Position + offset) * CFrame.Angles(0, 0, math.rad(90))
                else
                    auraMesh.Scale = Vector3.new(range*2, range*2, range*2)
                    auraPart.CFrame = CFrame.new(p.Position + offset)
                end
                
                auraPart.Parent = ws
            else
                auraPart.Parent = nil
            end
        else
            auraPart.Parent = nil
        end
    else
        auraPart.Parent = nil
    end

    for _, char in ipairs(getTargets()) do
        local h = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (h and hrp) then continue end

        buildESP(char)
        local d = espObjects[char]

        local function hideAll()
            if d.box then d.box.Visible = false end
            if d.nameText then d.nameText.Visible = false end
            if d.distText then d.distText.Visible = false end
            if d.hpBG then d.hpBG.Visible = false end
            if d.hpBar then d.hpBar.Visible = false end
            if d.tracer then d.tracer.Visible = false end
            for _, l in ipairs(d.corners) do if l then l.Visible = false end end
            for _, l in ipairs(d.skeleton) do if l then l.Visible = false end end
        end

        if not espOn or h.Health <= 0 then hideAll(); continue end
        if rootPos and (hrp.Position - rootPos).Magnitude > (flags["esp_max_dist"] or 800) then hideAll(); continue end

        applyChams(char)
        if flags["hitbox_on"] then expandHitbox(char) end

        local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then hideAll(); continue end

        local topSP = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
        local botSP = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
        local boxH = math.abs(botSP.Y - topSP.Y)
        local boxW = boxH * 0.55
        local bx, by = sp.X - boxW / 2, topSP.Y
        local style = flags["box_style"] or "Corner Box"

        if flags["box_esp"] then
            if style == "Full Box" then
                for _, l in ipairs(d.corners) do if l then l.Visible = false end end
                if d.box then
                    d.box.Size = Vector2.new(boxW, boxH); d.box.Position = Vector2.new(bx, by)
                    d.box.Color = box_color; d.box.Visible = true
                end
            elseif style == "Corner Box" then
                if d.box then d.box.Visible = false end
                local cL = math.min(boxW, boxH) * 0.28
                local co = d.corners
                if co[1] then co[1].From, co[1].To = Vector2.new(bx, by), Vector2.new(bx + cL, by) end
                if co[2] then co[2].From, co[2].To = Vector2.new(bx, by), Vector2.new(bx, by + cL) end
                if co[3] then co[3].From, co[3].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW - cL, by) end
                if co[4] then co[4].From, co[4].To = Vector2.new(bx + boxW, by), Vector2.new(bx + boxW, by + cL) end
                if co[5] then co[5].From, co[5].To = Vector2.new(bx, by + boxH), Vector2.new(bx + cL, by + boxH) end
                if co[6] then co[6].From, co[6].To = Vector2.new(bx, by + boxH), Vector2.new(bx, by + boxH - cL) end
                if co[7] then co[7].From, co[7].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW - cL, by + boxH) end
                if co[8] then co[8].From, co[8].To = Vector2.new(bx + boxW, by + boxH), Vector2.new(bx + boxW, by + boxH - cL) end
                for _, l in ipairs(co) do if l then l.Color = box_color; l.Visible = true end end
            else
                if d.box then d.box.Visible = false end
                for _, l in ipairs(d.corners) do if l then l.Visible = false end end
            end
        else
            if d.box then d.box.Visible = false end
            for _, l in ipairs(d.corners) do if l then l.Visible = false end end
        end

        if flags["name_esp"] and d.nameText then
            local plr = plrs:GetPlayerFromCharacter(char)
            d.nameText.Text = plr and plr.Name or char.Name
            d.nameText.Position = Vector2.new(sp.X, by - 14)
            d.nameText.Color = name_color
            d.nameText.Visible = true
        else 
            if d.nameText then d.nameText.Visible = false end 
        end

        if flags["dist_esp"] and rootPos and d.distText then
            local dist = math.round((hrp.Position - rootPos).Magnitude)
            d.distText.Text = dist .. "m"
            d.distText.Position = Vector2.new(sp.X, by + boxH + 3)
            d.distText.Color = dist_color
            d.distText.Visible = true
        else 
            if d.distText then d.distText.Visible = false end 
        end

        if flags["hp_esp"] then
            local pct = math.clamp(h.Health / math.max(h.MaxHealth, 1), 0, 1)
            local hbX, barH = bx - 6, boxH * pct
            if d.hpBG then
                d.hpBG.Size = Vector2.new(4, boxH); d.hpBG.Position = Vector2.new(hbX, by); d.hpBG.Visible = true
            end
            if d.hpBar then
                d.hpBar.Size = Vector2.new(4, barH); d.hpBar.Position = Vector2.new(hbX, by + boxH - barH)
                d.hpBar.Color = Color3.fromRGB(math.round((1 - pct) * 255), math.round(pct * 255), 0)
                d.hpBar.Visible = true
            end
        else
            if d.hpBG then d.hpBG.Visible = false end
            if d.hpBar then d.hpBar.Visible = false end
        end

        if flags["skel_esp"] then
            local rigType = h.RigType.Name
            local pairsToUse = rigType == "R15" and skel_pairs or skel_pairs_r6
            for i, pair in ipairs(pairsToUse) do
                local p1 = char:FindFirstChild(pair[1])
                local p2 = char:FindFirstChild(pair[2])
                local ln = d.skeleton[i]
                if p1 and p2 and ln then
                    local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                    local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                    if on1 and on2 then
                        ln.From = Vector2.new(s1.X, s1.Y); ln.To = Vector2.new(s2.X, s2.Y)
                        ln.Color = skel_color; ln.Visible = true
                    else
                        ln.Visible = false
                    end
                else
                    if ln then ln.Visible = false end
                end
            end
        else
            for _, l in ipairs(d.skeleton) do if l then l.Visible = false end end
        end

        if flags["tracers_on"] and d.tracer then
            local origin = flags["tracer_origin"] or "Mouse"
            local fromX = origin == "Mouse" and mp.X or vp.X / 2
            local fromY = origin == "Mouse" and mp.Y or vp.Y
            
            local dest = flags["tracer_dest"] or "Head"
            local destPart = char:FindFirstChild(dest) or hrp
            local destSP = cam:WorldToViewportPoint(destPart.Position)
            
            d.tracer.From = Vector2.new(fromX, fromY); d.tracer.To = Vector2.new(destSP.X, destSP.Y)
            d.tracer.Color = tracer_color; d.tracer.Thickness = flags["tracer_thick"] or 1; d.tracer.Visible = true
        else 
            if d.tracer then d.tracer.Visible = false end 
        end
    end

	if flags["auto_equip"] then
        local c = getChar()
        if c and c:GetAttribute("deployed") then
            local cw = c:GetAttribute("currentWeapon")
            local tw = flags["auto_equip_weapon"] or "Primary"
            if cw ~= tw then
                local idx = 1
                if tw == "Secondary" then idx = 2 elseif tw == "Knife" then idx = 3 end
                pcall(function() WeaponClient.setWeapon(idx) end)
            end
        end
    end
end)

print("e")
connect(run.Heartbeat, function()
    local rootPos = getRoot() and getRoot().Position
    if flags["radar_on"] and rootPos then
        for _, char in ipairs(getTargets()) do
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local h = char:FindFirstChildOfClass("Humanoid")
            if hrp and h and h.Health > 0 then
                local relPos = cam.CFrame:PointToObjectSpace(hrp.Position)
                local dist = (hrp.Position - rootPos).Magnitude
                if dist < (flags["radar_range"] or 500) then
                    if not radarDots[char] then
                        radarDots[char] = Instance.new("Frame", radarFrame)
                        radarDots[char].Size = UDim2.new(0, 4, 0, 4)
                        radarDots[char].BorderColor3 = Color3.new(0, 0, 0)
                        Instance.new("UICorner", radarDots[char]).CornerRadius = UDim.new(1, 0)
                    end
                    radarDots[char].BackgroundColor3 = radarDotColor
                    local scale = (flags["radar_size"] or 150) / 2
                    radarDots[char].Position = UDim2.new(0.5, relPos.X / (flags["radar_range"] or 500) * scale, 0.5, relPos.Z / (flags["radar_range"] or 500) * scale)
                else
                    if radarDots[char] then radarDots[char]:Destroy(); radarDots[char] = nil end
                end
            else
                if radarDots[char] then radarDots[char]:Destroy(); radarDots[char] = nil end
            end
        end
    else
        for _, dot in pairs(radarDots) do dot:Destroy() end
        radarDots = {}
    end
end)

connect(run.Heartbeat, function()
    for char, _ in pairs(espObjects) do
        if not char.Parent or not char:IsDescendantOf(ws) or not char:FindFirstChild("Humanoid") or char:FindFirstChildOfClass("Humanoid").Health <= 0 then
            destroyESP(char)
        end
    end
end)

connect(lp.Idled, function()
    if flags["anti_afk"] then
        if VIM then 
            VIM:SendKeyEvent(true, Enum.KeyCode.ButtonB, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.ButtonB, false, game) 
        end
    end
end)

task.spawn(function()
    task.wait(1)
    if isfile(library.directory .. "/silentload.cfg") then
        window.set_menu_visibility(false)
        flags["silent_load"] = true
    end
    local autoLoadPath = library.directory .. "/autoload.cfg"
    if isfile(autoLoadPath) then
        local cfgName = readfile(autoLoadPath)
        if cfgName and cfgName ~= "" then
            local path = dir .. cfgName .. ".cfg"
            if isfile(path) then
                library:load_config(readfile(path))
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
