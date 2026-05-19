local TweenService      = game:GetService("TweenService")
local UIS               = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONFIG = {
    PLACE_ID   = 0,
    VERSION    = "2.2.0",
    SUBMIT_URL = "https://toney-lobed-minh.ngrok-free.dev/submit",
    API_KEY    = "ptm_fd395def89854aa5",
}

if CONFIG.PLACE_ID ~= 0 and game.PlaceId ~= CONFIG.PLACE_ID then
    warn("[Phantasm] Wrong game."); return
end

-- ── Server fixture detection ──────────────────────────────────────────────────
-- PhantasmServer.lua must be running in ServerScriptService.
-- If it isn't, all tests fall back to local-only behaviour gracefully.
local BED     = ReplicatedStorage:FindFirstChild("PhantasmTestBed")
local REMOTES = BED and BED:FindFirstChild("Remotes")
local SCRIPTS_F = BED and BED:FindFirstChild("Scripts")
local WORLD_F   = BED and BED:FindFirstChild("World")
local HAS_BED   = BED ~= nil

-- Helper: wait up to `timeout` seconds for a remote to be reachable
local function getRemote(name, timeout)
    if not REMOTES then return nil end
    return REMOTES:FindFirstChild(name)
        or REMOTES:WaitForChild(name, timeout or 2)
end

-- ── Executor detection ────────────────────────────────────────────────────────
local EXECUTOR = "Unknown"
pcall(function()
    local n, v = identifyexecutor()
    EXECUTOR = (n or "?") .. " " .. (v or "")
end)

-- ── Palette ───────────────────────────────────────────────────────────────────
local C = {
    bg    = Color3.fromRGB(7,   7,   7),
    side  = Color3.fromRGB(11,  11,  11),
    panel = Color3.fromRGB(15,  15,  15),
    surf  = Color3.fromRGB(20,  20,  20),
    bord  = Color3.fromRGB(32,  32,  32),
    bord2 = Color3.fromRGB(50,  50,  50),
    white = Color3.fromRGB(255, 255, 255),
    pass  = Color3.fromRGB(34,  197, 94),
    fail  = Color3.fromRGB(239, 68,  68),
    warn  = Color3.fromRGB(234, 179, 8),
    miss  = Color3.fromRGB(70,  70,  70),
    dep   = Color3.fromRGB(148, 163, 184),
    txt   = Color3.fromRGB(230, 230, 230),
    sub   = Color3.fromRGB(110, 110, 110),
    mute  = Color3.fromRGB(38,  38,  38),
    link  = Color3.fromRGB(148, 163, 184),
    srv   = Color3.fromRGB(99,  102, 241), -- server-verified accent
}

local STATUS = {
    [200] = { color = C.pass, label = "Pass",    icon = "✓" },
    [400] = { color = C.miss, label = "Missing", icon = "—" },
    [401] = { color = C.dep,  label = "Dep",     icon = "!" },
    [500] = { color = C.fail, label = "Fail",    icon = "✕" },
    [0]   = { color = C.mute, label = "Idle",    icon = "·" },
}

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function mk(c, p, par)
    local o = Instance.new(c)
    if p then for k, v in pairs(p) do pcall(function() o[k] = v end) end end
    if par then o.Parent = par end
    return o
end
local function rnd(par, r)      return mk("UICorner",    {CornerRadius = UDim.new(0, r or 6)}, par) end
local function strk(par, c, t)  return mk("UIStroke",   {Color = c or C.bord, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, par) end
local function lst(par, dir, gap, ha, va)
    return mk("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        Padding             = UDim.new(0, gap or 0),
        SortOrder           = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Top,
    }, par)
end
local function pad(par, t, b, l, r)
    return mk("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft   = UDim.new(0, l or t or 0),
        PaddingRight  = UDim.new(0, r or l or t or 0),
    }, par)
end

-- ── GUI Root ──────────────────────────────────────────────────────────────────
local gui = mk("ScreenGui", {
    Name = "Phantasm", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true, DisplayOrder = 999,
})
if not pcall(function()
    if gethui then gui.Parent = gethui()
    else gui.Parent = game:GetService("CoreGui") end
end) then gui.Parent = game.Players.LocalPlayer.PlayerGui end

-- ── Window ────────────────────────────────────────────────────────────────────
local WIN_W, WIN_H = 1020, 620
local win = mk("Frame", {
    Size = UDim2.fromOffset(WIN_W, WIN_H),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.bg, BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)
rnd(win, 10); strk(win, C.bord, 1)

-- ── Titlebar ──────────────────────────────────────────────────────────────────
local tb = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = C.side, BorderSizePixel = 0,
}, win)
mk("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.bord, BorderSizePixel=0}, tb)
mk("Frame", {Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10), BackgroundColor3=C.side, BorderSizePixel=0}, tb)
rnd(tb, 10)

local function mkCtrl(col, x)
    local b = mk("TextButton", {
        Position=UDim2.fromOffset(x,0), Size=UDim2.new(0,12,1,0),
        BackgroundColor3=col, BorderSizePixel=0, Text="", AutoButtonColor=false,
    }, tb)
    rnd(b, 99); return b
end
local closeBtn = mkCtrl(Color3.fromRGB(255,90,85), 18)
mkCtrl(Color3.fromRGB(255,190,40), 36)
mkCtrl(Color3.fromRGB(40,210,60),  54)

mk("TextLabel", {
    Position=UDim2.fromOffset(80,0), Size=UDim2.new(0,100,1,0),
    BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=14,
    TextColor3=C.white, TextXAlignment=Enum.TextXAlignment.Left,
    Text="PHANTASM",
}, tb)
mk("TextLabel", {
    Position=UDim2.fromOffset(175,0), Size=UDim2.new(0,260,1,0),
    BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=13,
    TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Left,
    Text="executor suite · v" .. CONFIG.VERSION,
}, tb)

-- Server status indicator in titlebar
local srvBadge = mk("TextLabel", {
    AnchorPoint=Vector2.new(0,0.5),
    Position=UDim2.new(0,340,0.5,0), Size=UDim2.fromOffset(120,20),
    BackgroundColor3=HAS_BED and Color3.fromRGB(30,30,50) or C.mute,
    BorderSizePixel=0, Font=Enum.Font.GothamMedium, TextSize=10,
    TextColor3=HAS_BED and C.srv or C.sub,
    Text=HAS_BED and "⬡ SERVER LINKED" or "⬡ NO SERVER",
}, tb)
rnd(srvBadge, 3)

mk("TextLabel", {
    AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-16,0.5,0), Size=UDim2.fromOffset(200,30),
    BackgroundTransparency=1, Font=Enum.Font.GothamMedium, TextSize=12,
    TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Right,
    Text=EXECUTOR,
}, tb)

closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag
do
    local dragging, dragStart, startPos
    tb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=i.Position; startPos=win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                     startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

-- ── Body ──────────────────────────────────────────────────────────────────────
local body = mk("Frame", {
    Position=UDim2.fromOffset(0,48), Size=UDim2.new(1,0,1,-48),
    BackgroundTransparency=1,
}, win)
lst(body, Enum.FillDirection.Horizontal)

-- ── Sidebar ───────────────────────────────────────────────────────────────────
local sidebar = mk("Frame", {Size=UDim2.new(0,200,1,0), BackgroundColor3=C.side, BorderSizePixel=0}, body)
mk("Frame", {Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0), BackgroundColor3=C.bord, BorderSizePixel=0}, sidebar)
local sideScroll = mk("ScrollingFrame", {
    Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
    BorderSizePixel=0, ScrollBarThickness=2, ScrollBarImageColor3=C.bord2,
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(),
}, sidebar)
lst(sideScroll, Enum.FillDirection.Vertical, 1)
pad(sideScroll, 8, 8, 6, 6)

-- ── Content ───────────────────────────────────────────────────────────────────
local content = mk("Frame", {
    Size=UDim2.new(1,-200,1,0), BackgroundColor3=C.bg, BorderSizePixel=0, ClipsDescendants=true,
}, body)

local cbar = mk("Frame", {Size=UDim2.new(1,0,0,52), BackgroundColor3=C.panel, BorderSizePixel=0}, content)
mk("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.bord, BorderSizePixel=0}, cbar)

local cTitle = mk("TextLabel", {
    Position=UDim2.fromOffset(16,0), Size=UDim2.new(0.45,0,1,0),
    BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=14,
    TextColor3=C.txt, TextXAlignment=Enum.TextXAlignment.Left,
    Text="Select a category",
}, cbar)

local statsLbl = mk("TextLabel", {
    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.58,0,0.5,0),
    Size=UDim2.fromOffset(260,30), BackgroundTransparency=1,
    Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=C.sub,
    Text="—",
}, cbar)

local function mkBtn(text, ax, xo, w, col, textcol)
    local b = mk("TextButton", {
        AnchorPoint=Vector2.new(ax,0.5), Position=UDim2.new(ax,xo,0.5,0),
        Size=UDim2.fromOffset(w or 86,30), BackgroundColor3=col or C.surf,
        BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize=12,
        TextColor3=textcol or C.sub, Text=text, AutoButtonColor=false,
    }, cbar)
    rnd(b,5); strk(b,C.bord,1); return b
end
local runAllBtn = mkBtn("Run All", 0,  16,  80, C.surf,  C.sub)
local submitBtn = mkBtn("Submit",  1, -108, 84, C.surf,  C.sub)
local runBtn    = mkBtn("Run",     1,  -16, 84, C.white, Color3.fromRGB(0,0,0))
strk(runBtn, C.white, 1)

local rScroll = mk("ScrollingFrame", {
    Position=UDim2.fromOffset(0,52), Size=UDim2.new(1,0,1,-52),
    BackgroundTransparency=1, BorderSizePixel=0,
    ScrollBarThickness=3, ScrollBarImageColor3=C.bord2,
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new(),
    ClipsDescendants=true,
}, content)
lst(rScroll)

-- ── Result Row ────────────────────────────────────────────────────────────────
local function makeRow(name, statusCode, message, par, serverVerified)
    local s = STATUS[statusCode] or STATUS[0]
    local row = mk("Frame", {
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=C.bg, BorderSizePixel=0,
    }, par or rScroll)

    mk("Frame", {Size=UDim2.fromOffset(2,38), BackgroundColor3=s.color, BorderSizePixel=0}, row)

    mk("TextLabel", {
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(0,210,1,0),
        BackgroundTransparency=1, Font=Enum.Font.GothamMedium, TextSize=12,
        TextColor3=C.txt, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
        Text=name .. (serverVerified and " ⬡" or ""),
    }, row)

    local badge = mk("Frame", {Position=UDim2.fromOffset(226,8), Size=UDim2.fromOffset(76,22), BackgroundColor3=C.mute, BorderSizePixel=0}, row)
    rnd(badge, 3)
    mk("TextLabel", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        Font=Enum.Font.GothamBold, TextSize=11,
        TextColor3=s.color, Text=s.icon.." "..s.label,
    }, badge)

    mk("TextLabel", {
        Position=UDim2.fromOffset(312,0), Size=UDim2.new(1,-320,1,0),
        BackgroundTransparency=1, Font=Enum.Font.Gotham, TextSize=12,
        TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, Text=message or "",
    }, row)

    mk("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.bord, BorderSizePixel=0}, row)
    return row
end

local function clearResults()
    for _, c in ipairs(rScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end

local function makeSectionLabel(text, par)
    local f = mk("Frame", {Size=UDim2.new(1,0,0,28), BackgroundColor3=C.panel, BorderSizePixel=0}, par or rScroll)
    mk("Frame", {Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.bord, BorderSizePixel=0}, f)
    mk("TextLabel", {
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-12,1,0),
        BackgroundTransparency=1, Font=Enum.Font.GothamBold, TextSize=10,
        TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Left,
        Text=string.upper(text),
    }, f)
    return f
end

-- ─────────────────────────────────────────────────────────────────────────────
--  TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────────

local TESTS = {

    -- ── Environment ───────────────────────────────────────────────────────────
    {name="Environment", icon="ENV", tests={
        {name="getgenv", run=function()
            if not getgenv then return {status=400,message="not found"} end
            getgenv().__PH_MARKER=true
            if not __PH_MARKER then return {status=500,message="global not visible in env"} end
            getgenv().__PH_MARKER=nil
            return {status=200,message="write/read OK"}
        end},
        {name="getrenv", run=function()
            if not getrenv then return {status=400,message="not found"} end
            if getrenv()._G==_G then return {status=500,message="_G not isolated"} end
            if getrenv().game~=game then return {status=500,message="game ref mismatch"} end
            return {status=200,message="isolated, game ref OK"}
        end},
        {name="getgc", run=function()
            if not getgc then return {status=400,message="not found"} end
            local gc=getgc(true)
            if type(gc)~="table" or #gc==0 then return {status=500,message="empty/non-table"} end
            local hasF=false
            for _,v in ipairs(gc) do if type(v)=="function" then hasF=true; break end end
            if not hasF then return {status=500,message="no functions in GC"} end
            return {status=200,message=tostring(#gc).." objects"}
        end},
        {name="filtergc (Constants)", run=function()
            if not filtergc then return {status=400,message="not found"} end
            local marker="PH_FGCTEST_"..tostring(math.random(10000,99999))
            local target=function() return marker end
            task.wait(0.05)
            local r=filtergc("function",{Constants={marker},IgnoreExecutor=false},true)
            if r~=target then return {status=500,message="function not found via Constants"} end
            return {status=200,message="matched correctly"}
        end},
        {name="filtergc (Keys)", run=function()
            if not filtergc then return {status=400,message="not found"} end
            local key="PH_KEY_"..tostring(math.random(10000,99999))
            local tbl={[key]=true}
            task.wait(0.05)
            local r=filtergc("table",{Keys={key}},true)
            if r~=tbl then return {status=500,message="table not found via Keys"} end
            return {status=200,message="matched correctly"}
        end},
        {name="getreg", run=function()
            if not getreg then return {status=400,message="not found"} end
            local r=getreg()
            if type(r)~="table" then return {status=500,message="non-table"} end
            local n=0; for _ in pairs(r) do n+=1; if n>5 then break end end
            if n==0 then return {status=500,message="registry empty"} end
            return {status=200,message="populated"}
        end},
        {name="getexecutorname", run=function()
            local fn=getexecutorname or identifyexecutor
            if not fn then return {status=400,message="not found"} end
            local name=fn()
            if type(name)~="string" or #name==0 then return {status=500,message="empty/non-string"} end
            return {status=200,message=name}
        end},
        {name="setfpscap / getfpscap", run=function()
            if not setfpscap then return {status=400,message="setfpscap missing"} end
            if not getfpscap then return {status=400,message="getfpscap missing"} end
            setfpscap(60)
            local cap=getfpscap()
            if cap~=60 then return {status=500,message="expected 60, got "..tostring(cap)} end
            return {status=200,message="cap = "..tostring(cap)}
        end},
    }},

    -- ── Closures ──────────────────────────────────────────────────────────────
    {name="Closures", icon="CLO", tests={
        {name="islclosure", run=function()
            if not islclosure then return {status=400,message="not found"} end
            if not islclosure(function() end) then return {status=500,message="lua closure not identified"} end
            if islclosure(print) then return {status=500,message="C closure misidentified"} end
            return {status=200,message="lua/C distinction correct"}
        end},
        {name="iscclosure", run=function()
            if not iscclosure then return {status=400,message="not found"} end
            if iscclosure(function() end) then return {status=500,message="lua misidentified as C"} end
            if not iscclosure(print) then return {status=500,message="print not identified as C"} end
            return {status=200,message="C/lua distinction correct"}
        end},
        {name="isexecutorclosure", run=function()
            if not isexecutorclosure then return {status=400,message="not found"} end
            if not isexecutorclosure(isexecutorclosure) then return {status=500,message="executor global not identified"} end
            if not isexecutorclosure(function() end) then return {status=500,message="executor lua closure not identified"} end
            if isexecutorclosure(print) then return {status=500,message="roblox global misidentified"} end
            return {status=200,message="correct"}
        end},
        {name="newcclosure", run=function()
            if not newcclosure then return {status=400,message="not found"} end
            local f=function() return 42 end
            local c=newcclosure(f)
            if c==f then return {status=500,message="returned same reference"} end
            if c()~=42 then return {status=500,message="return value wrong"} end
            if iscclosure and not iscclosure(c) then return {status=500,message="result not C closure"} end
            return {status=200,message="wrapped + iscclosure OK"}
        end},
        {name="clonefunction", run=function()
            if not clonefunction then return {status=400,message="not found"} end
            local uv="ph_uv"
            local f=function() return uv end
            local c=clonefunction(f)
            if c==f then return {status=500,message="clone is same reference"} end
            if c()~=uv then return {status=500,message="clone returned wrong value"} end
            if debug and debug.setupvalue then
                debug.setupvalue(c,1,"modified")
                if f()~=uv then return {status=500,message="clone shares upvalue with original"} end
            end
            return {status=200,message="independent from original"}
        end},
        {name="hookfunction (L→L)", run=function()
            if not hookfunction then return {status=400,message="not found"} end
            local f=function() return 1 end
            local old=hookfunction(f,function() return 2 end)
            local got=f(); hookfunction(f,old)
            if got~=2 then return {status=500,message="hook not applied, got "..tostring(got)} end
            if old()~=1 then return {status=500,message="original broken"} end
            return {status=200,message="hook + restore OK"}
        end},
        {name="hookfunction (L→NC)", run=function()
            if not hookfunction then return {status=400,message="not found"} end
            if not newcclosure then return {status=401,message="newcclosure missing"} end
            local f=function() return "before" end
            local old=hookfunction(f,newcclosure(function() return "after" end))
            local got=f(); hookfunction(f,old)
            if got~="after" then return {status=500,message="NC hook not applied"} end
            return {status=200,message="OK"}
        end},
        {name="checkcaller", run=function()
            if not checkcaller then return {status=400,message="not found"} end
            if not checkcaller() then return {status=500,message="false in executor thread"} end
            local fromGame=false
            local be=Instance.new("BindableEvent")
            be.Event:Connect(function() if checkcaller then fromGame=checkcaller() end end)
            be:Fire(); task.wait(0.05); be:Destroy()
            if fromGame then return {status=500,message="game callback returned true"} end
            return {status=200,message="executor=true, game=false"}
        end},
        {name="getfunctionhash", run=function()
            if not getfunctionhash then return {status=400,message="not found"} end
            local f1,f2=function() return "a" end,function() return "b" end
            local h1,h2=getfunctionhash(f1),getfunctionhash(f2)
            if type(h1)~="string" then return {status=500,message="not a string"} end
            if #h1~=96 then return {status=500,message="expected 96 chars, got "..#h1} end
            if h1==h2 then return {status=500,message="different functions same hash"} end
            if getfunctionhash(f1)~=h1 then return {status=500,message="not deterministic"} end
            return {status=200,message="96-char SHA-384, unique + stable"}
        end},
        {name="isfunctionhooked", run=function()
            if not isfunctionhooked then return {status=400,message="not found"} end
            if not hookfunction then return {status=401,message="hookfunction missing"} end
            local f=function() return 1 end
            if isfunctionhooked(f) then return {status=500,message="unhooked reports hooked"} end
            local old=hookfunction(f,function() return 2 end)
            local isH=isfunctionhooked(f)
            hookfunction(f,old)
            if not isH then return {status=500,message="hooked reports not hooked"} end
            return {status=200,message="states detected correctly"}
        end},
    }},

    -- ── Cryptography ──────────────────────────────────────────────────────────
    {name="Cryptography", icon="CRY", tests={
        {name="crypt.base64encode", run=function()
            if not crypt or not crypt.base64encode then return {status=400,message="not found"} end
            if crypt.base64encode("test")~="dGVzdA==" then return {status=500,message="wrong output"} end
            if crypt.base64encode("")~="" then return {status=500,message="empty string failed"} end
            return {status=200,message="encoding correct"}
        end},
        {name="crypt.base64decode", run=function()
            if not crypt or not crypt.base64decode then return {status=400,message="not found"} end
            if crypt.base64decode("dGVzdA==")~="test" then return {status=500,message="wrong decode"} end
            return {status=200,message="decode correct"}
        end},
        {name="crypt.generatekey", run=function()
            if not crypt or not crypt.generatekey then return {status=400,message="not found"} end
            if not crypt.base64decode then return {status=401,message="base64decode missing"} end
            local k1,k2=crypt.generatekey(),crypt.generatekey()
            if #crypt.base64decode(k1)~=32 then return {status=500,message="not 32 bytes"} end
            if k1==k2 then return {status=500,message="keys not unique"} end
            return {status=200,message="32-byte keys, unique"}
        end},
        {name="crypt.encrypt / decrypt (CBC)", run=function()
            if not crypt or not crypt.encrypt then return {status=400,message="encrypt missing"} end
            if not crypt.decrypt then return {status=401,message="decrypt missing"} end
            local key=crypt.generatekey and crypt.generatekey() or nil
            if not key then return {status=401,message="generatekey missing"} end
            local plain="Phantasm CBC test 12345"
            local enc,iv=crypt.encrypt(plain,key,nil,"CBC")
            if not enc then return {status=500,message="encrypt returned nil"} end
            if enc==plain then return {status=500,message="ciphertext = plaintext"} end
            local dec=crypt.decrypt(enc,key,iv,"CBC")
            if dec~=plain then return {status=500,message="decrypt mismatch"} end
            return {status=200,message="CBC roundtrip OK"}
        end},
        {name="crypt.hash (multi-algo)", run=function()
            if not crypt or not crypt.hash then return {status=400,message="not found"} end
            local algos={"sha256","sha1","md5","sha384","sha512","sha3-256"}
            local lens={64,40,32,96,128,64}
            for i,alg in ipairs(algos) do
                local ok,h=pcall(crypt.hash,"phantasm",alg)
                if not ok then return {status=500,message="error on "..alg} end
                if #h~=lens[i] then return {status=500,message=alg.." len "..#h.." != "..lens[i]} end
            end
            return {status=200,message=tostring(#algos).." algorithms verified"}
        end},
        {name="crypt.generatebytes", run=function()
            if not crypt or not crypt.generatebytes then return {status=400,message="not found"} end
            if not crypt.base64decode then return {status=401,message="base64decode missing"} end
            local n=math.random(16,48)
            local b1,b2=crypt.generatebytes(n),crypt.generatebytes(n)
            if #crypt.base64decode(b1)~=n then return {status=500,message="length mismatch"} end
            if b1==b2 then return {status=500,message="identical output"} end
            return {status=200,message=n.." random bytes, unique"}
        end},
    }},

    -- ── Debug ─────────────────────────────────────────────────────────────────
    {name="Debug", icon="DBG", tests={
        {name="debug.getconstants", run=function()
            if not debug or not debug.getconstants then return {status=400,message="not found"} end
            local marker="PH_C_"..tostring(math.random(1000,9999))
            local f=loadstring("return function() print('"..marker.."') end")()
            local c=debug.getconstants(f)
            if type(c)~="table" then return {status=500,message="non-table"} end
            local found=false
            for _,v in ipairs(c) do if v==marker then found=true end end
            if not found then return {status=500,message="constant not found"} end
            return {status=200,message=tostring(#c).." constants"}
        end},
        {name="debug.getconstant", run=function()
            if not debug or not debug.getconstant then return {status=400,message="not found"} end
            local f=function() print("PH_CONST_SINGLE") end
            local found=false
            for i=1,20 do
                local ok,v=pcall(debug.getconstant,f,i)
                if not ok then break end
                if v=="PH_CONST_SINGLE" then found=true; break end
            end
            if not found then return {status=500,message="constant not located"} end
            return {status=200,message="located by index"}
        end},
        {name="debug.setconstant", run=function()
            if not debug or not debug.setconstant then return {status=400,message="not found"} end
            local f=function() return "original" end
            local idx=nil
            if debug.getconstants then
                for i,v in ipairs(debug.getconstants(f)) do
                    if v=="original" then idx=i; break end
                end
            end
            debug.setconstant(f,idx or 1,"modified")
            if f()~="modified" then return {status=500,message="constant not changed"} end
            return {status=200,message="constant mutated, function reflects change"}
        end},
        {name="debug.getproto", run=function()
            if not debug or not debug.getproto then return {status=400,message="not found"} end
            local outer=function() local inner=function() return "PH_PROTO" end end
            local p=debug.getproto(outer,1,true)
            if type(p)~="table" or not p[1] then return {status=500,message="not returned as table"} end
            if p[1]()~="PH_PROTO" then return {status=500,message="wrong return value"} end
            return {status=200,message="proto retrieved + callable"}
        end},
        {name="debug.getprotos", run=function()
            if not debug or not debug.getprotos then return {status=400,message="not found"} end
            local f=function() local a=function()end; local b=function()end; local c=function()end end
            local p=debug.getprotos(f)
            if type(p)~="table" or #p<3 then return {status=500,message="expected 3, got "..tostring(type(p)=="table" and #p or "?")} end
            return {status=200,message=tostring(#p).." protos"}
        end},
        {name="debug.getupvalues", run=function()
            if not debug or not debug.getupvalues then return {status=400,message="not found"} end
            local uv="UV_"..tostring(math.random(1000,9999))
            local f=function() return uv end
            local uvs=debug.getupvalues(f)
            local found=false
            for _,v in pairs(uvs) do if v==uv then found=true end end
            if not found then return {status=500,message="upvalue not in table"} end
            return {status=200,message="found"}
        end},
        {name="debug.getupvalue", run=function()
            if not debug or not debug.getupvalue then return {status=400,message="not found"} end
            local uv="UV_IDX_"..tostring(math.random(1000,9999))
            local f=function() return uv end
            local found=false
            for i=1,10 do
                local ok,v=pcall(debug.getupvalue,f,i)
                if not ok then break end
                if v==uv then found=true; break end
            end
            if not found then return {status=500,message="not found by index"} end
            return {status=200,message="located by index"}
        end},
        {name="debug.setupvalue", run=function()
            if not debug or not debug.setupvalue then return {status=400,message="not found"} end
            local uv="before"
            local f=function() return uv end
            debug.setupvalue(f,1,"after")
            if f()~="after" then return {status=500,message="upvalue not changed"} end
            return {status=200,message="mutated, function reflects change"}
        end},
        {name="debug.getinfo", run=function()
            if not debug or not debug.getinfo then return {status=400,message="not found"} end
            local f=function() end
            local ok,info=pcall(debug.getinfo,f)
            if not ok then return {status=500,message="threw error"} end
            if type(info)~="table" then return {status=500,message="non-table"} end
            return {status=200,message="table returned"}
        end},
        {name="debug.getstack / setstack", run=function()
            if not debug or not debug.getstack then return {status=400,message="getstack missing"} end
            local ok=pcall(debug.getstack,1)
            if not ok then return {status=500,message="getstack threw error"} end
            if not debug.setstack then return {status=400,message="setstack missing"} end
            return {status=200,message="both present"}
        end},
    }},

    -- ── Drawing API ───────────────────────────────────────────────────────────
    {name="Drawing API", icon="DRW", tests={
        {name="Drawing.new (all types)", run=function()
            if not Drawing then return {status=400,message="Drawing not found"} end
            local types={"Line","Text","Circle","Square","Quad","Triangle","Image"}
            local ok=0
            for _,t in ipairs(types) do
                local s,d=pcall(Drawing.new,t)
                if s and d then ok+=1; pcall(function() d.Visible=false end); pcall(function() d:Destroy() end) end
            end
            if ok<6 then return {status=500,message="only "..ok.."/"..#types.." types functional"} end
            return {status=200,message=ok.."/"..#types.." types OK"}
        end},
        {name="Drawing.Fonts", run=function()
            if not Drawing or not Drawing.Fonts then return {status=400,message="not found"} end
            if Drawing.Fonts.UI~=0 then return {status=500,message="UI font ID wrong"} end
            if Drawing.Fonts.System~=1 then return {status=500,message="System ID wrong"} end
            if Drawing.Fonts.Plex~=2 then return {status=500,message="Plex ID wrong"} end
            if Drawing.Fonts.Monospace~=3 then return {status=500,message="Monospace ID wrong"} end
            return {status=200,message="all 4 IDs correct"}
        end},
        {name="getrenderproperty", run=function()
            if not getrenderproperty then return {status=400,message="not found"} end
            if not Drawing then return {status=401,message="Drawing missing"} end
            local d=Drawing.new("Line"); d.Thickness=7
            local t=getrenderproperty(d,"Thickness"); d:Destroy()
            if t~=7 then return {status=500,message="expected 7, got "..tostring(t)} end
            return {status=200,message="correct"}
        end},
        {name="setrenderproperty", run=function()
            if not setrenderproperty then return {status=400,message="not found"} end
            if not Drawing then return {status=401,message="Drawing missing"} end
            local d=Drawing.new("Square")
            setrenderproperty(d,"Visible",false)
            local v=d.Visible; d:Destroy()
            if v~=false then return {status=500,message="Visible not changed"} end
            return {status=200,message="property written"}
        end},
        {name="isrenderobj", run=function()
            if not isrenderobj then return {status=400,message="not found"} end
            if not Drawing then return {status=401,message="Drawing missing"} end
            local d=Drawing.new("Circle")
            local r1,r2,r3=isrenderobj(d),isrenderobj({}),isrenderobj("str")
            d:Destroy()
            if not r1 then return {status=500,message="Drawing returned false"} end
            if r2 then return {status=500,message="table returned true"} end
            if r3 then return {status=500,message="string returned true"} end
            return {status=200,message="all three checks correct"}
        end},
        {name="cleardrawcache", run=function()
            if not cleardrawcache then return {status=400,message="not found"} end
            local ok,err=pcall(cleardrawcache)
            if not ok then return {status=500,message="error: "..tostring(err)} end
            return {status=200,message="cleared without error"}
        end},
    }},

    -- ── Filesystem ────────────────────────────────────────────────────────────
    {name="Filesystem", icon="FS", tests={
        {name="readfile / writefile", run=function()
            if not writefile or not readfile then return {status=400,message="not found"} end
            local c="ph_"..tostring(math.random(10000,99999))
            writefile(".ph_test.txt",c)
            local r=readfile(".ph_test.txt"); pcall(delfile,".ph_test.txt")
            if r~=c then return {status=500,message="mismatch: "..tostring(r)} end
            return {status=200,message="roundtrip OK"}
        end},
        {name="appendfile", run=function()
            if not appendfile then return {status=400,message="not found"} end
            if not writefile or not readfile then return {status=401,message="writefile/readfile missing"} end
            writefile(".ph_ap.txt","hello")
            appendfile(".ph_ap.txt"," world")
            local r=readfile(".ph_ap.txt"); pcall(delfile,".ph_ap.txt")
            if r~="hello world" then return {status=500,message="got: "..tostring(r)} end
            return {status=200,message="append correct"}
        end},
        {name="isfile / isfolder", run=function()
            if not isfile or not isfolder then return {status=400,message="not found"} end
            if not writefile or not makefolder then return {status=401,message="deps missing"} end
            writefile(".ph_if.txt","x"); makefolder(".ph_ifl")
            local a,b,c,d=isfile(".ph_if.txt"),isfolder(".ph_ifl"),isfile(".ph_nx.txt"),isfolder(".ph_if.txt")
            pcall(delfile,".ph_if.txt"); pcall(delfolder,".ph_ifl")
            if not a then return {status=500,message="isfile false for existing"} end
            if not b then return {status=500,message="isfolder false for existing"} end
            if c then return {status=500,message="isfile true for non-existent"} end
            if d then return {status=500,message="isfolder true for file"} end
            return {status=200,message="all 4 checks correct"}
        end},
        {name="listfiles", run=function()
            if not listfiles then return {status=400,message="not found"} end
            if not makefolder or not writefile then return {status=401,message="deps missing"} end
            makefolder(".ph_ls")
            writefile(".ph_ls/a.txt","a"); writefile(".ph_ls/b.txt","b"); writefile(".ph_ls/c.txt","c")
            local files=listfiles(".ph_ls"); pcall(delfolder,".ph_ls")
            if type(files)~="table" then return {status=500,message="non-table"} end
            if #files~=3 then return {status=500,message="expected 3, got "..tostring(#files)} end
            return {status=200,message="3 files listed"}
        end},
        {name="makefolder / delfolder", run=function()
            if not makefolder or not delfolder then return {status=400,message="not found"} end
            if not isfolder then return {status=401,message="isfolder missing"} end
            makefolder(".ph_mkdel")
            if not isfolder(".ph_mkdel") then return {status=500,message="folder not created"} end
            delfolder(".ph_mkdel")
            if isfolder(".ph_mkdel") then return {status=500,message="still exists after delete"} end
            return {status=200,message="create + delete OK"}
        end},
        {name="delfile", run=function()
            if not delfile then return {status=400,message="not found"} end
            if not writefile or not isfile then return {status=401,message="deps missing"} end
            writefile(".ph_del.txt","bye"); delfile(".ph_del.txt")
            if isfile(".ph_del.txt") then return {status=500,message="still exists"} end
            return {status=200,message="deleted"}
        end},
        {name="loadfile", run=function()
            if not loadfile then return {status=400,message="not found"} end
            if not writefile then return {status=401,message="writefile missing"} end
            writefile(".ph_lf.lua","return ... + 100")
            local fn,err=loadfile(".ph_lf.lua"); pcall(delfile,".ph_lf.lua")
            if not fn then return {status=500,message="failed: "..(err or "?")} end
            local ok,r=pcall(fn,5)
            if not ok or r~=105 then return {status=500,message="result wrong: "..tostring(r)} end
            return {status=200,message="loaded + executed correctly"}
        end},
        {name="getcustomasset", run=function()
            if not getcustomasset then return {status=400,message="not found"} end
            if not writefile then return {status=401,message="writefile missing"} end
            writefile(".ph_asset.png","\137PNG\r\n\26\n\0\0\0\rIHDR\0\0\0\1\0\0\0\1\8\2\0\0\0\144wS\222\0\0\0\12IDAT\8\215c\248\15\0\0\1\1\0\5\24\213N\0\0\0\0IEND\174B`\130")
            local ok,r=pcall(getcustomasset,".ph_asset.png"); pcall(delfile,".ph_asset.png")
            if not ok then return {status=500,message="error: "..tostring(r)} end
            if type(r)~="string" or not r:match("rbxasset://") then return {status=500,message="not an rbxasset URL"} end
            return {status=200,message="rbxasset:// URL returned"}
        end},
    }},

    -- ── Instances ─────────────────────────────────────────────────────────────
    {name="Instances", icon="INS", tests={
        {name="getinstances", run=function()
            if not getinstances then return {status=400,message="not found"} end
            local list=getinstances()
            if type(list)~="table" or #list==0 then return {status=500,message="empty/non-table"} end
            return {status=200,message=tostring(#list).." instances"}
        end},
        {name="getnilinstances", run=function()
            if not getnilinstances then return {status=400,message="not found"} end
            local list=getnilinstances()
            if type(list)~="table" or #list==0 then return {status=500,message="empty/non-table"} end
            for _,inst in ipairs(list) do
                if inst.Parent~=nil then return {status=500,message="non-nil parent found"} end
            end
            return {status=200,message=tostring(#list).." nil-parented"}
        end},
        {name="gethui", run=function()
            if not gethui then return {status=400,message="not found"} end
            local h=gethui()
            if typeof(h)~="Instance" then return {status=500,message="not an Instance"} end
            return {status=200,message=h.ClassName}
        end},
        {name="cloneref", run=function()
            if not cloneref then return {status=400,message="not found"} end
            local part=Instance.new("Part")
            local clone=cloneref(part)
            if part==clone then return {status=500,message="clone is identical reference"} end
            local name="PH_"..tostring(math.random(1000,9999))
            part.Name=name
            local synced=clone.Name==name
            part:Destroy()
            if not synced then return {status=500,message="name not reflected through clone"} end
            return {status=200,message="distinct ref, property sync confirmed"}
        end},
        {name="compareinstances", run=function()
            if not compareinstances then return {status=400,message="not found"} end
            if not cloneref then return {status=401,message="cloneref missing"} end
            local p1,p2=Instance.new("Part"),Instance.new("Part")
            local c1=cloneref(p1)
            local eq1,eq2=compareinstances(p1,c1),compareinstances(p1,p2)
            p1:Destroy(); p2:Destroy()
            if not eq1 then return {status=500,message="cloneref pair not equal"} end
            if eq2 then return {status=500,message="different parts considered equal"} end
            return {status=200,message="clone=equal, different=not equal"}
        end},
        {name="fireclickdetector", run=function()
            if not fireclickdetector then return {status=400,message="not found"} end
            -- Prefer server fixture (more accurate than a local Part)
            local cdFixture = WORLD_F
                and WORLD_F:FindFirstChild("ClickPart")
                and WORLD_F.ClickPart:FindFirstChild("TestCD")
            local cd, owner, suffix
            if cdFixture then
                cd = cdFixture; suffix = "server fixture"
            else
                owner = Instance.new("Part")
                cd = Instance.new("ClickDetector", owner)
                suffix = "local fixture"
            end
            local fired=false
            local conn=cd.MouseClick:Connect(function() fired=true end)
            local ok,err=pcall(fireclickdetector,cd,0)
            task.wait(0.05); conn:Disconnect()
            if owner then owner:Destroy() end
            if not ok then return {status=500,message="error: "..tostring(err)} end
            if not fired then return {status=500,message="MouseClick did not fire ("..suffix..")"} end
            return {status=200,message="MouseClick fired ("..suffix..")"}
        end},
        {name="fireproximityprompt", run=function()
            if not fireproximityprompt then return {status=400,message="not found"} end
            local ppFixture = WORLD_F
                and WORLD_F:FindFirstChild("PPPart")
                and WORLD_F.PPPart:FindFirstChild("TestPP")
            local pp, owner, suffix
            if ppFixture then
                pp = ppFixture; suffix = "server fixture"
            else
                owner = Instance.new("Part")
                pp = Instance.new("ProximityPrompt", owner)
                suffix = "local fixture"
            end
            local trig=false
            local conn=pp.Triggered:Connect(function() trig=true end)
            local ok,err=pcall(fireproximityprompt,pp)
            task.wait(0.05); conn:Disconnect()
            if owner then owner:Destroy() end
            if not ok then return {status=500,message="error: "..tostring(err)} end
            if not trig then return {status=500,message="Triggered did not fire ("..suffix..")"} end
            return {status=200,message="fired ("..suffix..")"}
        end},
        {name="getcallbackvalue", run=function()
            if not getcallbackvalue then return {status=400,message="not found"} end
            -- Server fixture BindableFunction is more reliable than a game-local one
            local bfFixture = WORLD_F and WORLD_F:FindFirstChild("TestBF")
            local bf, suffix
            if bfFixture then
                bf = bfFixture; suffix = "server fixture"
            else
                bf = Instance.new("BindableFunction"); suffix = "local fixture"
            end
            local fn = function() return "PH_CBV" end
            if not bfFixture then bf.OnInvoke = fn end
            local got = bfFixture
                and getcallbackvalue(bf, "OnInvoke")    -- already has a handler set on server
                or  getcallbackvalue(bf, "OnInvoke")
            if not bfFixture then bf:Destroy() end
            -- For server fixture we can't compare functions directly, just confirm non-nil function
            if type(got) ~= "function" then
                return {status=500,message="non-function returned ("..suffix..")"}
            end
            return {status=200,message="callback retrieved ("..suffix..")"}
        end},
        {name="getconnections", run=function()
            if not getconnections then return {status=400,message="not found"} end
            local be=Instance.new("BindableEvent")
            be.Event:Connect(function() end)
            local conns=getconnections(be.Event); be:Destroy()
            if type(conns)~="table" or #conns==0 then return {status=500,message="no connections"} end
            local c=conns[1]
            if type(c.Disconnect)~="function" then return {status=500,message="missing Disconnect"} end
            if type(c.Function)~="function" then return {status=500,message="missing Function"} end
            if type(c.Enable)~="function" then return {status=500,message="missing Enable"} end
            if type(c.Disable)~="function" then return {status=500,message="missing Disable"} end
            return {status=200,message="all sUNC fields present"}
        end},
        {name="gethiddenproperty", run=function()
            if not gethiddenproperty then return {status=400,message="not found"} end
            -- Try server fixture Fire first (avoids creating a local one)
            local fireFixture = WORLD_F and WORLD_F:FindFirstChild("FirePart")
                and WORLD_F.FirePart:FindFirstChild("TestFire")
            local fire = fireFixture or Instance.new("Fire")
            local ok,v,hidden=pcall(gethiddenproperty,fire,"size_xml")
            if not fireFixture then fire:Destroy() end
            if not ok then return {status=500,message="error: "..tostring(v)} end
            if v~=5 then return {status=500,message="expected 5, got "..tostring(v)} end
            if not hidden then return {status=500,message="isHidden not true"} end
            return {status=200,message="size_xml=5, hidden=true"..(fireFixture and " (server fixture)" or "")}
        end},
        {name="sethiddenproperty", run=function()
            if not sethiddenproperty then return {status=400,message="not found"} end
            if not gethiddenproperty then return {status=401,message="gethiddenproperty missing"} end
            local fire=Instance.new("Fire")
            local ok,e=pcall(sethiddenproperty,fire,"size_xml",99)
            local v=gethiddenproperty(fire,"size_xml"); fire:Destroy()
            if not ok then return {status=500,message="error: "..tostring(e)} end
            if v~=99 then return {status=500,message="not changed, got "..tostring(v)} end
            return {status=200,message="size_xml=99 verified"}
        end},
        {name="isscriptable / setscriptable", run=function()
            if not isscriptable then return {status=400,message="isscriptable missing"} end
            if not setscriptable then return {status=400,message="setscriptable missing"} end
            local fire=Instance.new("Fire")
            if isscriptable(fire,"size_xml") then fire:Destroy(); return {status=500,message="size_xml should not be scriptable"} end
            if not isscriptable(fire,"Size") then fire:Destroy(); return {status=500,message="Size should be scriptable"} end
            local was=setscriptable(fire,"size_xml",true)
            if was then fire:Destroy(); return {status=500,message="setscriptable returned true"} end
            if not isscriptable(fire,"size_xml") then fire:Destroy(); return {status=500,message="still not scriptable after set"} end
            fire:Destroy()
            return {status=200,message="scriptability toggled correctly"}
        end},
    }},

    -- ── Metatables ────────────────────────────────────────────────────────────
    {name="Metatables", icon="META", tests={
        {name="getrawmetatable", run=function()
            if not getrawmetatable then return {status=400,message="not found"} end
            local mt={__metatable="locked",__index=function() return 1 end}
            local obj=setmetatable({},mt)
            if getrawmetatable(obj)~=mt then return {status=500,message="wrong metatable"} end
            return {status=200,message="bypassed __metatable lock"}
        end},
        {name="setrawmetatable", run=function()
            if not setrawmetatable then return {status=400,message="not found"} end
            local obj=setmetatable({},{__metatable="locked",__index=function() return false end})
            setrawmetatable(obj,{__index=function() return true end})
            if not obj.anything then return {status=500,message="new metatable not applied"} end
            return {status=200,message="replaced, new __index active"}
        end},
        {name="hookmetamethod", run=function()
            if not hookmetamethod then return {status=400,message="not found"} end
            local base=newcclosure and newcclosure(function() return false end) or function() return false end
            local obj=setmetatable({},{__index=base,__metatable="locked"})
            local hook=newcclosure and newcclosure(function() return true end) or function() return true end
            local ref=hookmetamethod(obj,"__index",hook)
            local result=obj.test
            hookmetamethod(obj,"__index",ref)
            if result~=true then return {status=500,message="hook did not change return"} end
            if ref()~=false then return {status=500,message="original broken after restore"} end
            return {status=200,message="applied + restored"}
        end},
        {name="getnamecallmethod", run=function()
            if not getnamecallmethod then return {status=400,message="not found"} end
            if not hookmetamethod then return {status=401,message="hookmetamethod missing"} end
            local captured,ref
            local hook=(newcclosure and newcclosure or function(x) return x end)(function(...)
                if not captured then captured=getnamecallmethod() end
                return ref(...)
            end)
            ref=hookmetamethod(game,"__namecall",hook)
            game:GetService("Lighting")
            hookmetamethod(game,"__namecall",ref)
            if captured~="GetService" then return {status=500,message="expected GetService, got "..tostring(captured)} end
            return {status=200,message="captured: GetService"}
        end},
        {name="isreadonly", run=function()
            if not isreadonly then return {status=400,message="not found"} end
            local t={}
            if isreadonly(t) then return {status=500,message="mutable reports readonly"} end
            table.freeze(t)
            if not isreadonly(t) then return {status=500,message="frozen does not report readonly"} end
            return {status=200,message="mutable=false, frozen=true"}
        end},
        {name="setreadonly", run=function()
            if not setreadonly then return {status=400,message="not found"} end
            if not isreadonly then return {status=401,message="isreadonly missing"} end
            local t={x=1}; table.freeze(t)
            setreadonly(t,false)
            local ok=pcall(function() t.x=2 end)
            if not ok then return {status=500,message="still read-only after setreadonly(false)"} end
            if t.x~=2 then return {status=500,message="value not changed"} end
            return {status=200,message="unfrozen, mutation confirmed"}
        end},
    }},

    -- ── Scripts ───────────────────────────────────────────────────────────────
    {name="Scripts", icon="SCR", tests={
        {name="loadstring", run=function()
            if not loadstring then return {status=400,message="not found"} end
            local fn,err=loadstring("return 40 + 2")
            if not fn then return {status=500,message="failed: "..(err or "?")} end
            if fn()~=42 then return {status=500,message="wrong result"} end
            local _,compErr=loadstring("!!! invalid")
            if type(compErr)~="string" then return {status=500,message="no compile error returned"} end
            local envFn=loadstring("return game ~= nil")
            if not envFn or not envFn() then return {status=500,message="game not accessible in chunk"} end
            return {status=200,message="exec + error + env OK"}
        end},
        {name="getscripts", run=function()
            if not getscripts then return {status=400,message="not found"} end
            local s=getscripts()
            if type(s)~="table" or #s==0 then return {status=500,message="empty/non-table"} end
            if not s[1]:IsA("LuaSourceContainer") then return {status=500,message="not a script"} end
            return {status=200,message=tostring(#s).." scripts"}
        end},
        {name="getrunningscripts", run=function()
            if not getrunningscripts then return {status=400,message="not found"} end
            local s=getrunningscripts()
            if type(s)~="table" or #s==0 then return {status=500,message="empty/non-table"} end
            return {status=200,message=tostring(#s).." running"}
        end},
        {name="getloadedmodules", run=function()
            if not getloadedmodules then return {status=400,message="not found"} end
            local m=getloadedmodules()
            if type(m)~="table" or #m==0 then return {status=500,message="empty/non-table"} end
            if not m[1]:IsA("ModuleScript") then return {status=500,message="not a ModuleScript"} end
            return {status=200,message=tostring(#m).." modules"}
        end},
        {name="getscriptbytecode", run=function()
            if not getscriptbytecode then return {status=400,message="not found"} end
            -- Prefer stable server fixture; fall back to Animate
            local target = (SCRIPTS_F and SCRIPTS_F:FindFirstChild("PhantasmTarget"))
                or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Animate"))
            if not target then return {status=401,message="no target script found"} end
            local bc=getscriptbytecode(target)
            if type(bc)~="string" or #bc==0 then return {status=500,message="empty/non-string"} end
            local src = SCRIPTS_F and SCRIPTS_F:FindFirstChild("PhantasmTarget") and "server fixture" or "Animate"
            return {status=200,message=tostring(#bc).." bytes ("..src..")"}
        end},
        {name="getscripthash", run=function()
            if not getscripthash then return {status=400,message="not found"} end
            local target = (SCRIPTS_F and SCRIPTS_F:FindFirstChild("PhantasmTarget"))
                or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Animate"))
            if not target then return {status=401,message="no target script found"} end
            local h=getscripthash(target)
            if type(h)~="string" or #h==0 then return {status=500,message="empty/non-string"} end
            if getscripthash(target)~=h then return {status=500,message="not deterministic"} end
            return {status=200,message="len="..tostring(#h)..", stable"}
        end},
        {name="getscriptclosure", run=function()
            if not getscriptclosure then return {status=400,message="not found"} end
            local target = (SCRIPTS_F and SCRIPTS_F:FindFirstChild("PhantasmTarget"))
                or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Animate"))
            if not target then return {status=401,message="no target script found"} end
            local ok,fn=pcall(getscriptclosure,target)
            if not ok then return {status=500,message="error: "..tostring(fn)} end
            if type(fn)~="function" then return {status=500,message="not a function"} end
            return {status=200,message="closure returned"}
        end},
        {name="getsenv", run=function()
            if not getsenv then return {status=400,message="not found"} end
            local target = (SCRIPTS_F and SCRIPTS_F:FindFirstChild("PhantasmTarget"))
                or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Animate"))
            if not target then return {status=401,message="no target script found"} end
            local env=getsenv(target)
            if type(env)~="table" then return {status=500,message="non-table"} end
            if env.script~=target then return {status=500,message="env.script mismatch"} end
            return {status=200,message="env.script matches"}
        end},
        {name="getthreadidentity / setthreadidentity", run=function()
            if not getthreadidentity then return {status=400,message="getthreadidentity missing"} end
            if not setthreadidentity then return {status=400,message="setthreadidentity missing"} end
            local id=getthreadidentity()
            if type(id)~="number" or id<2 or id>8 then
                return {status=500,message="identity "..tostring(id).." outside range 2-8"}
            end
            setthreadidentity(3)
            local got=getthreadidentity()
            setthreadidentity(id)
            if got~=3 then return {status=500,message="expected 3, got "..tostring(got)} end
            return {status=200,message="identity="..tostring(id)..", set/restore OK"}
        end},
        {name="decompile", run=function()
            if not decompile then return {status=400,message="not found"} end
            local target = (SCRIPTS_F and SCRIPTS_F:FindFirstChild("PhantasmTarget"))
                or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Animate"))
            if not target then return {status=401,message="no target script found"} end
            local ok,r=pcall(decompile,target)
            if not ok then return {status=500,message="error: "..tostring(r)} end
            if type(r)~="string" or #r==0 then return {status=500,message="empty/non-string"} end
            return {status=200,message=tostring(#r).." chars decompiled"}
        end},
    }},

    -- ── Signals ───────────────────────────────────────────────────────────────
    {name="Signals", icon="SIG", tests={
        {name="getconnections (multi)", run=function()
            if not getconnections then return {status=400,message="not found"} end
            local be=Instance.new("BindableEvent")
            for _=1,3 do be.Event:Connect(function() end) end
            local conns=getconnections(be.Event); be:Destroy()
            if type(conns)~="table" or #conns<3 then
                return {status=500,message="expected 3+, got "..tostring(type(conns)=="table" and #conns or "?")}
            end
            return {status=200,message=tostring(#conns).." connections"}
        end},
        {name="connection.Fire", run=function()
            if not getconnections then return {status=400,message="getconnections missing"} end
            local be=Instance.new("BindableEvent")
            local args=nil
            be.Event:Connect(function(a,b) args={a,b} end)
            local conns=getconnections(be.Event)
            if not conns[1] or type(conns[1].Fire)~="function" then
                be:Destroy(); return {status=400,message="Fire not available"}
            end
            conns[1]:Fire("hello",42); task.wait(0.05); be:Destroy()
            if not args then return {status=500,message="did not invoke"} end
            if args[1]~="hello" or args[2]~=42 then return {status=500,message="args wrong"} end
            return {status=200,message="args passed correctly"}
        end},
        {name="connection.Disable / Enable", run=function()
            if not getconnections then return {status=400,message="getconnections missing"} end
            local be=Instance.new("BindableEvent")
            local count=0
            be.Event:Connect(function() count+=1 end)
            local conns=getconnections(be.Event)
            if not conns[1] or type(conns[1].Disable)~="function" then
                be:Destroy(); return {status=400,message="Disable not available"}
            end
            conns[1]:Disable(); be:Fire(); task.wait(0.05)
            conns[1]:Enable(); be:Fire(); task.wait(0.05)
            be:Destroy()
            if count~=1 then return {status=500,message="expected 1 fire, got "..tostring(count)} end
            return {status=200,message="disable blocked, enable restored"}
        end},
        {name="firesignal", run=function()
            if not firesignal then return {status=400,message="not found"} end
            local be=Instance.new("BindableEvent")
            local fired=false
            be.Event:Connect(function() fired=true end)
            firesignal(be.Event); task.wait(0.05); be:Destroy()
            if not fired then return {status=500,message="signal not fired"} end
            return {status=200,message="fired"}
        end},
        {name="replicatesignal", run=function()
            if not replicatesignal then return {status=400,message="not found"} end
            return {status=200,message="present (no safe auto-test)"}
        end},
    }},

    -- ── Remotes  (requires PhantasmServer.lua) ────────────────────────────────
    {name="Remotes", icon="REM", tests={
        {name="server bed detected", run=function()
            if not HAS_BED then return {status=400,message="PhantasmTestBed not in ReplicatedStorage — run PhantasmServer.lua"} end
            return {status=200,message="bed found in ReplicatedStorage"}
        end},
        {name="fireremoteevent (Echo)", run=function()
            if not HAS_BED then return {status=400,message="no server bed"} end
            if not fireremoteevent then return {status=400,message="fireremoteevent missing"} end
            local re=getRemote("Echo")
            if not re then return {status=400,message="Echo remote not found"} end
            local got=nil
            local conn=re.OnClientEvent:Connect(function(v) got=v end)
            local marker="PH_ECHO_"..tostring(math.random(10000,99999))
            fireremoteevent(re,marker)
            local t=tick()
            repeat task.wait(0.05) until got or tick()-t>5
            conn:Disconnect()
            if not got then return {status=500,message="no echo in 5s"} end
            if got~=marker then return {status=500,message="echo mismatch: "..tostring(got)} end
            return {status=200,message="echo confirmed ("..string.format("%.2f",tick()-t).."s)"}
        end},
        {name="invokeserver (Ping)", run=function()
            if not HAS_BED then return {status=400,message="no server bed"} end
            if not invokeserver then return {status=400,message="invokeserver missing"} end
            local rf=getRemote("Ping")
            if not rf then return {status=400,message="Ping remote not found"} end
            local ok,ts,echo=pcall(invokeserver,rf,"hello")
            if not ok then return {status=500,message="error: "..tostring(ts)} end
            if type(ts)~="number" then return {status=500,message="timestamp not a number"} end
            if echo~="hello" then return {status=500,message="vararg not echoed"} end
            return {status=200,message="roundtrip OK, ts="..tostring(ts)}
        end},
        {name="invokeserver (Reflect)", run=function()
            if not HAS_BED then return {status=400,message="no server bed"} end
            if not invokeserver then return {status=400,message="invokeserver missing"} end
            local rf=getRemote("Reflect")
            if not rf then return {status=400,message="Reflect remote not found"} end
            local ok,a,b,c=pcall(invokeserver,rf,1,"two",true)
            if not ok then return {status=500,message="error: "..tostring(a)} end
            if a~=1 or b~="two" or c~=true then return {status=500,message="arg mismatch"} end
            return {status=200,message="multi-arg reflect correct"}
        end},
        {name="server-side vuln check", run=function()
            if not HAS_BED then return {status=400,message="no server bed"} end
            if not invokeserver then return {status=400,message="invokeserver missing"} end
            local rf=getRemote("ServerRun")
            if not rf then return {status=400,message="ServerRun remote not found"} end
            local ok,res=pcall(invokeserver,rf)
            if not ok then return {status=500,message="invoke error: "..tostring(res)} end
            if type(res)~="table" then return {status=500,message="non-table response"} end
            -- Aggregate server results
            local pass,fail=0,0
            for _,v in pairs(res) do
                if type(v)=="table" then
                    if v.status==200 then pass+=1 else fail+=1 end
                end
            end
            if fail>0 then return {status=500,message=fail.." server check(s) FAILED — see Vulnerabilities"} end
            return {status=200,message=pass.." server-side checks passed"}
        end},
    }},

    -- ── WebSocket ─────────────────────────────────────────────────────────────
    {name="WebSocket", icon="WS", tests={
        {name="WebSocket.connect (API)", run=function()
            if not WebSocket or not WebSocket.connect then return {status=400,message="not found"} end
            local ok,ws=pcall(WebSocket.connect,"ws://echo.websocket.events")
            if not ok then return {status=500,message="error: "..tostring(ws)} end
            if type(ws.Send)~="function" then return {status=500,message="missing Send"} end
            if type(ws.Close)~="function" then return {status=500,message="missing Close"} end
            if not ws.OnMessage then return {status=500,message="missing OnMessage"} end
            if not ws.OnClose then return {status=500,message="missing OnClose"} end
            pcall(function() ws:Close() end)
            return {status=200,message="API surface OK"}
        end},
        {name="WebSocket send/receive (echo)", run=function()
            if not WebSocket or not WebSocket.connect then return {status=400,message="WebSocket missing"} end
            local ok,ws=pcall(WebSocket.connect,"ws://echo.websocket.events")
            if not ok then return {status=500,message="connect failed"} end
            local recv=nil
            local marker="PH_ECHO_"..tostring(math.random(10000,99999))
            ws.OnMessage:Connect(function(msg) recv=msg end)
            ws:Send(marker)
            local t=tick()
            repeat task.wait(0.1) until recv or tick()-t>6
            pcall(function() ws:Close() end)
            if not recv then return {status=500,message="no echo in 6s"} end
            if not recv:find(marker,1,true) then return {status=500,message="echo mismatch"} end
            return {status=200,message="roundtrip OK ("..string.format("%.2f",tick()-t).."s)"}
        end},
    }},

    -- ── Cache ─────────────────────────────────────────────────────────────────
    {name="Cache", icon="CACHE", tests={
        {name="cache.invalidate", run=function()
            if not cache or not cache.invalidate then return {status=400,message="not found"} end
            local cont=Instance.new("Folder")
            local part=Instance.new("Part",cont)
            cache.invalidate(cont:FindFirstChild("Part"))
            local newRef=cont:FindFirstChild("Part"); cont:Destroy()
            if part==newRef then return {status=500,message="reference not invalidated"} end
            return {status=200,message="new reference after invalidate"}
        end},
        {name="cache.iscached", run=function()
            if not cache or not cache.iscached then return {status=400,message="not found"} end
            if not cache.invalidate then return {status=401,message="cache.invalidate missing"} end
            local part=Instance.new("Part")
            if not cache.iscached(part) then return {status=500,message="new instance not cached"} end
            cache.invalidate(part)
            if cache.iscached(part) then return {status=500,message="still cached after invalidate"} end
            part:Destroy()
            return {status=200,message="cached→invalidated correct"}
        end},
        {name="cache.replace", run=function()
            if not cache or not cache.replace then return {status=400,message="not found"} end
            local p,f=Instance.new("Part"),Instance.new("Fire")
            local ok,err=pcall(cache.replace,p,f)
            p:Destroy(); f:Destroy()
            if not ok then return {status=500,message="error: "..tostring(err)} end
            return {status=200,message="executed without error"}
        end},
    }},

    -- ── Bit Library ───────────────────────────────────────────────────────────
    {name="Bit", icon="BIT", tests={
        {name="bit32.band", run=function()
            if not bit32 or not bit32.band then return {status=400,message="not found"} end
            if bit32.band(0xFF,0x0F)~=0x0F then return {status=500,message="wrong result"} end
            if bit32.band(0xFF,0x00)~=0x00 then return {status=500,message="AND with 0 wrong"} end
            return {status=200,message="correct"}
        end},
        {name="bit32.bor", run=function()
            if not bit32 or not bit32.bor then return {status=400,message="not found"} end
            if bit32.bor(0xF0,0x0F)~=0xFF then return {status=500,message="wrong result"} end
            return {status=200,message="correct"}
        end},
        {name="bit32.bxor", run=function()
            if not bit32 or not bit32.bxor then return {status=400,message="not found"} end
            if bit32.bxor(0xFF,0xFF)~=0x00 then return {status=500,message="XOR same wrong"} end
            if bit32.bxor(0xF0,0x0F)~=0xFF then return {status=500,message="XOR diff wrong"} end
            return {status=200,message="correct"}
        end},
        {name="bit32.bnot", run=function()
            if not bit32 or not bit32.bnot then return {status=400,message="not found"} end
            local r=bit32.bnot(0)
            if r~=0xFFFFFFFF then return {status=500,message="bnot(0) expected 0xFFFFFFFF, got "..string.format("0x%X",r)} end
            return {status=200,message="bnot(0)=0xFFFFFFFF correct"}
        end},
        {name="bit32.lshift / rshift", run=function()
            if not bit32 or not bit32.lshift then return {status=400,message="lshift missing"} end
            if not bit32.rshift then return {status=400,message="rshift missing"} end
            if bit32.lshift(1,4)~=16 then return {status=500,message="lshift(1,4) != 16"} end
            if bit32.rshift(16,4)~=1 then return {status=500,message="rshift(16,4) != 1"} end
            return {status=200,message="lshift + rshift correct"}
        end},
        {name="bit32.arshift", run=function()
            if not bit32 or not bit32.arshift then return {status=400,message="not found"} end
            if bit32.arshift(8,1)~=4 then return {status=500,message="arshift(8,1) != 4"} end
            return {status=200,message="correct"}
        end},
        {name="bit32.extract / replace", run=function()
            if not bit32 or not bit32.extract then return {status=400,message="extract missing"} end
            if not bit32.replace then return {status=400,message="replace missing"} end
            local n=0b11001010
            if bit32.extract(n,3,3)~=0b001 then return {status=500,message="extract wrong"} end
            local r=bit32.replace(0,5,2,4)
            if bit32.extract(r,2,4)~=5 then return {status=500,message="replace/extract roundtrip wrong"} end
            return {status=200,message="extract + replace correct"}
        end},
        {name="bit32.countlz / countrz", run=function()
            if not bit32 then return {status=400,message="bit32 missing"} end
            if not bit32.countlz then return {status=400,message="countlz missing"} end
            if not bit32.countrz then return {status=400,message="countrz missing"} end
            if bit32.countlz(1)~=31 then return {status=500,message="countlz(1) != 31"} end
            if bit32.countrz(8)~=3 then return {status=500,message="countrz(8) != 3"} end
            return {status=200,message="countlz + countrz correct"}
        end},
    }},

    -- ── Input ─────────────────────────────────────────────────────────────────
    {name="Input", icon="INP", tests={
        {name="getmouseposition / mouse.getpos", run=function()
            local fn=getmouseposition or (mouse and mouse.getpos)
            if not fn then return {status=400,message="not found"} end
            local ok,r=pcall(fn)
            if not ok then return {status=500,message="error: "..tostring(r)} end
            if typeof(r)~="Vector2" and (type(r)~="table" or not r.X) then
                return {status=500,message="expected Vector2, got "..typeof(r)}
            end
            return {status=200,message="Vector2 returned"}
        end},
        {name="mouse1click / mouse2click", run=function()
            if not mouse1click and not mouse2click then return {status=400,message="not found"} end
            local ok1=mouse1click and pcall(mouse1click) or true
            local ok2=mouse2click and pcall(mouse2click) or true
            if not ok1 then return {status=500,message="mouse1click threw"} end
            if not ok2 then return {status=500,message="mouse2click threw"} end
            return {status=200,message="callable without error"}
        end},
        {name="mouse1press / mouse1release", run=function()
            if not mouse1press and not mouse1release then return {status=400,message="not found"} end
            local ok1=mouse1press and pcall(mouse1press) or true
            task.wait(0.05)
            local ok2=mouse1release and pcall(mouse1release) or true
            if not ok1 then return {status=500,message="mouse1press threw"} end
            if not ok2 then return {status=500,message="mouse1release threw"} end
            return {status=200,message="press/release callable"}
        end},
        {name="keypress / keyrelease", run=function()
            if not keypress and not keyrelease then return {status=400,message="not found"} end
            local ok1=keypress and pcall(keypress,0x10) or true
            task.wait(0.05)
            local ok2=keyrelease and pcall(keyrelease,0x10) or true
            if not ok1 then return {status=500,message="keypress threw"} end
            if not ok2 then return {status=500,message="keyrelease threw"} end
            return {status=200,message="callable without error"}
        end},
        {name="mousescroll", run=function()
            if not mousescroll then return {status=400,message="not found"} end
            local ok,err=pcall(mousescroll,0,0,1)
            if not ok then return {status=500,message="error: "..tostring(err)} end
            return {status=200,message="callable"}
        end},
        {name="setmousepos / mousemoveabs", run=function()
            local fn=setmousepos or mousemoveabs
            if not fn then return {status=400,message="not found"} end
            local ok,err=pcall(fn,100,100)
            if not ok then return {status=500,message="error: "..tostring(err)} end
            return {status=200,message="callable"}
        end},
        {name="isrbxactive / isgameactive", run=function()
            local fn=isrbxactive or isgameactive
            if not fn then return {status=400,message="not found"} end
            local ok,v=pcall(fn)
            if not ok then return {status=500,message="error: "..tostring(v)} end
            if type(v)~="boolean" then return {status=500,message="expected boolean, got "..type(v)} end
            return {status=200,message="returned "..tostring(v)}
        end},
    }},

    -- ── Miscellaneous ─────────────────────────────────────────────────────────
    {name="Miscellaneous", icon="MISC", tests={
        {name="request (HTTP GET)", run=function()
            if not request then return {status=400,message="not found"} end
            local ok,res=pcall(request,{Url="https://httpbin.org/get",Method="GET"})
            if not ok then return {status=500,message="error: "..tostring(res)} end
            if type(res)~="table" then return {status=500,message="non-table response"} end
            if res.StatusCode~=200 then return {status=500,message="status "..tostring(res.StatusCode)} end
            return {status=200,message="status 200, body received"}
        end},
        {name="setclipboard", run=function()
            if not setclipboard then return {status=400,message="not found"} end
            local ok,err=pcall(setclipboard,"PH_CLIP_TEST")
            if not ok then return {status=500,message="threw: "..tostring(err)} end
            return {status=200,message="callable"}
        end},
        {name="getclipboard", run=function()
            if not getclipboard then return {status=400,message="not found"} end
            if not setclipboard then return {status=401,message="setclipboard missing"} end
            local marker="PH_CLIP_"..tostring(math.random(10000,99999))
            pcall(setclipboard,marker)
            local ok,v=pcall(getclipboard)
            if not ok then return {status=500,message="threw: "..tostring(v)} end
            if v~=marker then return {status=500,message="mismatch: "..tostring(v)} end
            return {status=200,message="roundtrip OK"}
        end},
        {name="queue_on_teleport", run=function()
            if not queue_on_teleport then return {status=400,message="not found"} end
            return {status=200,message="present"}
        end},
        {name="lz4compress / lz4decompress", run=function()
            if not lz4compress then return {status=400,message="lz4compress missing"} end
            if not lz4decompress then return {status=400,message="lz4decompress missing"} end
            local raw="Phantasm lz4 test payload 1234567890 abcdefgh"
            local comp=lz4compress(raw)
            if type(comp)~="string" then return {status=500,message="not a string"} end
            local decomp=lz4decompress(comp,#raw)
            if decomp~=raw then return {status=500,message="decompress mismatch"} end
            return {status=200,message="roundtrip OK ("..#comp.."→"..#raw.." bytes)"}
        end},
        {name="messagebox", run=function()
            if not messagebox then return {status=400,message="not found"} end
            return {status=200,message="present (blocks thread)"}
        end},
        {name="getobjects", run=function()
            if not getobjects then return {status=400,message="not found"} end
            local ok,r=pcall(getobjects,"rbxassetid://0")
            if not ok then return {status=500,message="error: "..tostring(r)} end
            return {status=200,message="callable"}
        end},
        {name="syn.protect_gui / protect_gui", run=function()
            local fn=(syn and syn.protect_gui) or protect_gui
            if not fn then return {status=400,message="not found"} end
            local frame=Instance.new("ScreenGui")
            local ok,err=pcall(fn,frame)
            frame:Destroy()
            if not ok then return {status=500,message="error: "..tostring(err)} end
            return {status=200,message="callable"}
        end},
    }},

    -- ── Vulnerabilities ───────────────────────────────────────────────────────
    {name="Vulnerabilities", icon="VUL", tests={
        {name="HttpRbxApiService blocked", run=function()
            local blocked,total=0,0
            for _,m in ipairs({"PostAsync","PostAsyncFullUrl","GetAsync","GetAsyncFullUrl","RequestAsync"}) do
                total+=1
                local _,e=pcall(function() game:GetService("HttpRbxApiService")[m]() end)
                if e~="Argument 1 missing or nil" then blocked+=1 end
            end
            if blocked==total then return {status=200,message="all "..total.." methods blocked"} end
            return {status=500,message=(total-blocked).."/"..total.." NOT blocked — VULNERABLE"}
        end},
        {name="MarketplaceService.PerformPurchase blocked", run=function()
            for _,m in ipairs({"PerformPurchase","PerformPurchaseV2"}) do
                local _,e=pcall(function() game:GetService("MarketplaceService")[m]() end)
                if e=="Argument 1 missing or nil" then
                    return {status=500,message=m.." NOT blocked — VULNERABLE"}
                end
            end
            return {status=200,message="variants blocked"}
        end},
        {name="GetRobuxBalance blocked", run=function()
            local s,e=pcall(function() return game:GetService("MarketplaceService"):GetRobuxBalance() end)
            if s then return {status=500,message="returned balance — VULNERABLE"} end
            return {status=200,message="blocked"}
        end},
        {name="BrowserService blocked", run=function()
            local vuln={}
            for _,m in ipairs({"EmitHybridEvent","ExecuteJavaScript","OpenBrowserWindow","OpenNativeOverlay","ReturnToJavaScript","SendCommand"}) do
                local _,e=pcall(function() game:GetService("BrowserService")[m]() end)
                if e=="Argument 1 missing or nil" then table.insert(vuln,m) end
            end
            if #vuln>0 then return {status=500,message=table.concat(vuln,", ").." NOT blocked"} end
            return {status=200,message="all 6 methods blocked"}
        end},
        {name="HttpService.RequestInternal blocked", run=function()
            local _,e=pcall(function() game:GetService("HttpService"):RequestInternal() end)
            if e=="Argument 1 missing or nil" then return {status=500,message="NOT blocked — VULNERABLE"} end
            return {status=200,message="blocked"}
        end},
        {name="MessageBusService blocked", run=function()
            local vuln={}
            local methods={"Call","GetLast","GetMessageId","MakeRequest","Publish","Subscribe",
                           "GetProtocolMethodRequestMessageId","GetProtocolMethodResponseMessageId"}
            for _,m in ipairs(methods) do
                local _,e=pcall(function() game:GetService("MessageBusService")[m]() end)
                if e=="Argument 1 missing or nil" then table.insert(vuln,m) end
            end
            if #vuln>0 then return {status=500,message=table.concat(vuln,", ").." NOT blocked"} end
            return {status=200,message="all tested methods blocked"}
        end},
        {name="ScriptContext.AddCoreScriptLocal blocked", run=function()
            local _,e=pcall(function() game:GetService("ScriptContext"):AddCoreScriptLocal() end)
            if e=="Argument 1 missing or nil" then return {status=500,message="NOT blocked — VULNERABLE"} end
            return {status=200,message="blocked"}
        end},
        {name="OpenCloudService.HttpRequestAsync blocked", run=function()
            local _,e=pcall(function() game:GetService("OpenCloudService"):HttpRequestAsync() end)
            if e=="Argument 1 missing or nil" then return {status=500,message="NOT blocked — VULNERABLE"} end
            return {status=200,message="blocked"}
        end},
        {name="request() auth cookie leak", run=function()
            if not request then return {status=400,message="request() not found"} end
            local ok,res=pcall(request,{Url="https://economy.roblox.com/v1/user/currency",Method="GET"})
            if not ok then return {status=200,message="errored (likely blocked)"} end
            if type(res)=="table" and tostring(res.Body or ""):match('^{.-"robux"') then
                return {status=500,message="auth cookie sent to Roblox API — VULNERABLE"}
            end
            return {status=200,message="no auth cookie leaked"}
        end},
        {name="game:HttpGet() auth cookie leak", run=function()
            local ok,res=pcall(function() return game:HttpGet("https://economy.roblox.com/v1/user/currency") end)
            if not ok then return {status=200,message="errored (likely blocked)"} end
            if tostring(res):match('^{.-"robux"') then
                return {status=500,message="cookie leaked via HttpGet — VULNERABLE"}
            end
            return {status=200,message="no leak"}
        end},
        {name="CoreGui screenshot/record blocked", run=function()
            local vuln={}
            if pcall(function() game:GetService("CoreGui"):TakeScreenshot() end) then table.insert(vuln,"TakeScreenshot") end
            if pcall(function() game:GetService("CoreGui"):ToggleRecording() end) then table.insert(vuln,"ToggleRecording") end
            if #vuln>0 then return {status=500,message=table.concat(vuln,", ").." NOT blocked"} end
            return {status=200,message="both blocked"}
        end},
        {name="syn.get_thread_identity level", run=function()
            if not getthreadidentity then return {status=400,message="getthreadidentity missing"} end
            local id=getthreadidentity()
            if id<6 then return {status=500,message="identity "..id.." < 6 — may lack full access"} end
            return {status=200,message="identity "..id.." ≥ 6, good"}
        end},
        -- Server-side vulnerability cross-check (requires PhantasmServer.lua)
        {name="server-side service protection", run=function()
            if not HAS_BED then return {status=400,message="PhantasmServer.lua not running — skip"} end
            if not invokeserver then return {status=400,message="invokeserver missing"} end
            local rf=getRemote("ServerRun")
            if not rf then return {status=400,message="ServerRun remote missing"} end
            local ok,res=pcall(invokeserver,rf)
            if not ok then return {status=500,message="invoke error: "..tostring(res)} end
            local msgs={}
            for k,v in pairs(res) do
                if type(v)=="table" and v.status==500 then
                    table.insert(msgs,k..": "..tostring(v.message))
                end
            end
            if #msgs>0 then return {status=500,message=table.concat(msgs," | ")} end
            return {status=200,message="all server-side checks passed"}
        end},
    }},
}

-- ── State ─────────────────────────────────────────────────────────────────────
local resultsData     = {}
local currentCategory = nil
local running         = false

-- ── Sidebar ───────────────────────────────────────────────────────────────────
local function getSideBtn(name)
    for _,c in ipairs(sideScroll:GetChildren()) do
        if c:IsA("TextButton") and c.Name==name then return c end
    end
end

local function setActive(btn)
    for _,c in ipairs(sideScroll:GetChildren()) do
        if c:IsA("TextButton") then
            local isA=c==btn
            c.BackgroundColor3=isA and C.surf or C.side
            local bar=c:FindFirstChild("_bar")
            if bar then bar.BackgroundTransparency=isA and 0 or 1 end
            local lbl=c:FindFirstChildWhichIsA("TextLabel")
            if lbl then lbl.TextColor3=isA and C.white or C.sub end
        end
    end
end

local function showCategory(cat)
    currentCategory=cat
    cTitle.Text=cat.name
    statsLbl.Text=tostring(#cat.tests).." tests"
    setActive(getSideBtn(cat.name))
    clearResults()
    if resultsData[cat.name] then
        makeSectionLabel(cat.name)
        for _,r in ipairs(resultsData[cat.name]) do
            makeRow(r.name,r.status,r.message)
        end
    else
        makeSectionLabel(cat.name)
        for _,t in ipairs(cat.tests) do
            makeRow(t.name,0,"not run")
        end
    end
end

for _,cat in ipairs(TESTS) do
    local btn=mk("TextButton",{
        Name=cat.name, Size=UDim2.new(1,0,0,38),
        BackgroundColor3=C.side, BorderSizePixel=0,
        Text="", AutoButtonColor=false,
    },sideScroll)
    rnd(btn,4)
    mk("Frame",{Name="_bar", Size=UDim2.fromOffset(2,38), BackgroundColor3=C.white, BackgroundTransparency=1, BorderSizePixel=0},btn)
    mk("TextLabel",{
        Position=UDim2.fromOffset(12,0), Size=UDim2.new(1,-12,1,0),
        BackgroundTransparency=1, Font=Enum.Font.GothamMedium, TextSize=12,
        TextColor3=C.sub, TextXAlignment=Enum.TextXAlignment.Left,
        Text="["..cat.icon.."] "..cat.name,
    },btn)
    btn.MouseButton1Click:Connect(function() showCategory(cat) end)
end

-- ── Counters ──────────────────────────────────────────────────────────────────
local function countCat(name)
    if not resultsData[name] then return 0,0,0,0 end
    local p,f,m,d=0,0,0,0
    for _,r in ipairs(resultsData[name]) do
        if     r.status==200 then p+=1
        elseif r.status==500 then f+=1
        elseif r.status==400 then m+=1
        elseif r.status==401 then d+=1 end
    end
    return p,f,m,d
end

local function gatherAll()
    local all={}
    local totals={pass=0,fail=0,missing=0,dependency=0}
    for _,cat in ipairs(TESTS) do
        if resultsData[cat.name] then
            for _,r in ipairs(resultsData[cat.name]) do
                table.insert(all,{category=cat.name,test=r.name,status=r.status,
                    label=(STATUS[r.status] or STATUS[0]).label,message=r.message})
                if     r.status==200 then totals.pass+=1
                elseif r.status==500 then totals.fail+=1
                elseif r.status==400 then totals.missing+=1
                elseif r.status==401 then totals.dependency+=1 end
            end
        end
    end
    return all,totals
end

-- ── Run category ──────────────────────────────────────────────────────────────
local function runCat(cat,scroll)
    local results={}
    resultsData[cat.name]=results
    for _,t in ipairs(cat.tests) do
        local ph=makeRow(t.name,0,"running...",scroll)
        task.wait(0.02)
        local ok,res=pcall(t.run)
        local status=(ok and res and res.status) or 500
        local message=(ok and res and res.message) or ("error: "..tostring(res))
        table.insert(results,{name=t.name,status=status,message=message})
        local s=STATUS[status] or STATUS[0]
        for _,ch in ipairs(ph:GetChildren()) do
            if ch:IsA("Frame") and ch.Size==UDim2.fromOffset(2,38) then
                ch.BackgroundColor3=s.color
            elseif ch:IsA("Frame") and ch.Size==UDim2.fromOffset(76,22) then
                ch.BackgroundColor3=C.mute
                local lbl=ch:FindFirstChildWhichIsA("TextLabel")
                if lbl then lbl.TextColor3=s.color; lbl.Text=s.icon.." "..s.label end
            elseif ch:IsA("TextLabel") then
                if ch.Position.X.Offset==312 then ch.Text=message end
            end
        end
        task.wait(0.03)
    end
    return results
end

-- ── Buttons ───────────────────────────────────────────────────────────────────
runBtn.MouseButton1Click:Connect(function()
    if running then return end
    if not currentCategory then cTitle.Text="select a category first"; return end
    running=true
    runBtn.Text="running"; runBtn.BackgroundColor3=C.mute; runBtn.TextColor3=C.sub
    clearResults()
    makeSectionLabel(currentCategory.name)
    runCat(currentCategory,rScroll)
    local p,f,m=countCat(currentCategory.name)
    local tot=p+f+m
    local pct=tot>0 and math.round(p/tot*100) or 0
    statsLbl.Text=p.." pass · "..f.." fail · "..m.." miss · "..pct.."%"
    running=false
    runBtn.Text="Run"; runBtn.BackgroundColor3=C.white; runBtn.TextColor3=Color3.fromRGB(0,0,0)
end)

runAllBtn.MouseButton1Click:Connect(function()
    if running then return end
    running=true
    runAllBtn.Text="running..."; runAllBtn.BackgroundColor3=C.mute; runAllBtn.TextColor3=C.sub
    for _,cat in ipairs(TESTS) do
        currentCategory=cat
        cTitle.Text=cat.name.." (batch)"
        local btn=getSideBtn(cat.name)
        if btn then setActive(btn) end
        clearResults()
        makeSectionLabel(cat.name)
        runCat(cat,rScroll)
    end
    local _,totals=gatherAll()
    local tot=totals.pass+totals.fail+totals.missing
    local pct=tot>0 and math.round(totals.pass/tot*100) or 0
    cTitle.Text="Complete"
    statsLbl.Text=totals.pass.." pass · "..totals.fail.." fail · "..totals.missing.." miss · "..pct.."%"
    running=false
    runAllBtn.Text="Run All"; runAllBtn.BackgroundColor3=C.surf; runAllBtn.TextColor3=C.sub
end)

-- ── Submit ────────────────────────────────────────────────────────────────────
local popup=mk("Frame",{
    AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-10),
    Size=UDim2.fromOffset(400,46), BackgroundColor3=C.panel, BorderSizePixel=0,
    Visible=false, ZIndex=20,
},win)
rnd(popup,6); strk(popup,C.bord2,1)
mk("TextLabel",{Position=UDim2.fromOffset(14,0),Size=UDim2.fromOffset(60,46),BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Left,Text="view at:",ZIndex=20},popup)
local popupLink=mk("TextButton",{Position=UDim2.fromOffset(72,0),Size=UDim2.new(1,-130,1,0),BackgroundTransparency=1,Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=C.link,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Text="",AutoButtonColor=false,ZIndex=20},popup)
local copyBtn2=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),Size=UDim2.fromOffset(52,28),BackgroundColor3=C.white,BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Color3.fromRGB(0,0,0),Text="COPY",AutoButtonColor=false,ZIndex=20},popup)
rnd(copyBtn2,4)

copyBtn2.MouseButton1Click:Connect(function()
    if setclipboard then
        pcall(setclipboard,popupLink.Text)
        copyBtn2.Text="DONE"; copyBtn2.BackgroundColor3=C.pass
        task.delay(2,function() copyBtn2.Text="COPY"; copyBtn2.BackgroundColor3=C.white end)
    end
end)
popupLink.MouseButton1Click:Connect(function()
    if setclipboard then pcall(setclipboard,popupLink.Text) end
end)

submitBtn.MouseButton1Click:Connect(function()
    local allResults,totals=gatherAll()
    if #allResults==0 then statsLbl.Text="run tests first"; return end
    submitBtn.Text="sending..."; submitBtn.BackgroundColor3=C.mute; submitBtn.TextColor3=C.sub
    local payload=HttpService:JSONEncode({
        executor=EXECUTOR,
        timestamp=os.time(),
        version=CONFIG.VERSION,
        server_linked=HAS_BED,
        totals=totals,
        results=allResults,
    })
    local ok,res=pcall(request,{
        Url=CONFIG.SUBMIT_URL, Method="POST",
        Headers={["Content-Type"]="application/json",["Accept"]="application/json",["x-api-key"]=CONFIG.API_KEY},
        Body=payload,
    })
    if not ok then
        statsLbl.Text="submit error: "..tostring(res)
        submitBtn.Text="Submit"; submitBtn.BackgroundColor3=C.surf; submitBtn.TextColor3=C.sub
        return
    end
    local success,data=pcall(function() return HttpService:JSONDecode(res.Body) end)
    if success and res.StatusCode>=200 and res.StatusCode<300 and data and data.view then
        popup.Visible=true; popupLink.Text=data.view
        statsLbl.Text="submitted successfully"
    else
        statsLbl.Text="error "..tostring(res.StatusCode)
    end
    submitBtn.Text="Submit"; submitBtn.BackgroundColor3=C.surf; submitBtn.TextColor3=C.sub
end)
