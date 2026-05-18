--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

-- Instances: 44 | Scripts: 6 | Modules: 4 | Tags: 0
local G2L = {};

-- StarterGui.plex.
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
G2L["1"]["Name"] = [[plex.]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["ResetOnSpawn"] = false;


-- StarterGui.plex..core
G2L["2"] = Instance.new("LocalScript", G2L["1"]);
G2L["2"]["Name"] = [[core]];


-- StarterGui.plex..Modules
G2L["3"] = Instance.new("Folder", G2L["1"]);
G2L["3"]["Name"] = [[Modules]];


-- StarterGui.plex..Modules.decompiler
G2L["4"] = Instance.new("ModuleScript", G2L["3"]);
G2L["4"]["Name"] = [[decompiler]];


-- StarterGui.plex..Modules.scanner
G2L["5"] = Instance.new("ModuleScript", G2L["3"]);
G2L["5"]["Name"] = [[scanner]];


-- StarterGui.plex..Modules.uicontroller
G2L["6"] = Instance.new("ModuleScript", G2L["3"]);
G2L["6"]["Name"] = [[uicontroller]];


-- StarterGui.plex..Modules.propcontroller
G2L["7"] = Instance.new("ModuleScript", G2L["3"]);
G2L["7"]["Name"] = [[propcontroller]];


-- StarterGui.plex..main
G2L["8"] = Instance.new("Frame", G2L["1"]);
G2L["8"]["BorderSizePixel"] = 0;
G2L["8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8"]["Size"] = UDim2.new(1.00383, 0, 1, 0);
G2L["8"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8"]["Name"] = [[main]];
G2L["8"]["BackgroundTransparency"] = 1;


-- StarterGui.plex..main.explorer
G2L["9"] = Instance.new("Frame", G2L["8"]);
G2L["9"]["BorderSizePixel"] = 3;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["9"]["Size"] = UDim2.new(0.13422, 0, 0.66742, 0);
G2L["9"]["Position"] = UDim2.new(0.86183, 0, 0.06747, 0);
G2L["9"]["Name"] = [[explorer]];
G2L["9"]["BackgroundTransparency"] = 0.2;


-- StarterGui.plex..main.explorer.left
G2L["a"] = Instance.new("Frame", G2L["9"]);
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["a"]["Size"] = UDim2.new(0.01894, 0, 0.99997, 0);
G2L["a"]["Position"] = UDim2.new(-0.02516, 0, -0, 0);
G2L["a"]["Name"] = [[left]];
G2L["a"]["BackgroundTransparency"] = 0.1;


-- StarterGui.plex..main.explorer.search
G2L["b"] = Instance.new("Frame", G2L["9"]);
G2L["b"]["BorderSizePixel"] = 0;
G2L["b"]["BackgroundColor3"] = Color3.fromRGB(53, 53, 53);
G2L["b"]["Size"] = UDim2.new(1.00502, 0, 0.04896, 0);
G2L["b"]["Position"] = UDim2.new(-0.00623, 0, 0.00892, 0);
G2L["b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["b"]["Name"] = [[search]];


-- StarterGui.plex..main.explorer.search.input
G2L["c"] = Instance.new("TextBox", G2L["b"]);
G2L["c"]["CursorPosition"] = -1;
G2L["c"]["Name"] = [[input]];
G2L["c"]["PlaceholderColor3"] = Color3.fromRGB(101, 101, 101);
G2L["c"]["TextWrapped"] = true;
G2L["c"]["TextSize"] = 14;
G2L["c"]["TextColor3"] = Color3.fromRGB(215, 215, 215);
G2L["c"]["TextScaled"] = true;
G2L["c"]["BackgroundColor3"] = Color3.fromRGB(53, 53, 53);
G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c"]["PlaceholderText"] = [[Search workspace]];
G2L["c"]["Size"] = UDim2.new(0.91721, 0, -0.78, 0);
G2L["c"]["Position"] = UDim2.new(0.04016, 0, 0.86654, 0);
G2L["c"]["Text"] = [[]];
G2L["c"]["BackgroundTransparency"] = 0.6;


-- StarterGui.plex..main.explorer.name
G2L["d"] = Instance.new("Frame", G2L["9"]);
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["d"]["Size"] = UDim2.new(1.02395, 0, 0.03548, 0);
G2L["d"]["Position"] = UDim2.new(-0.02516, 0, -0.02656, 0);
G2L["d"]["Name"] = [[name]];


-- StarterGui.plex..main.explorer.name.lablel
G2L["e"] = Instance.new("TextLabel", G2L["d"]);
G2L["e"]["BorderSizePixel"] = 0;
G2L["e"]["TextSize"] = 14;
G2L["e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(90, 90, 90);
G2L["e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["e"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
G2L["e"]["BackgroundTransparency"] = 0.6;
G2L["e"]["Size"] = UDim2.new(1.01093, 0, -1.0005, 0);
G2L["e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["e"]["Text"] = [[    Explorer]];
G2L["e"]["Name"] = [[lablel]];
G2L["e"]["Position"] = UDim2.new(-0.00314, 0, 1, 0);


-- StarterGui.plex..main.explorer.name.x
G2L["f"] = Instance.new("TextButton", G2L["d"]);
G2L["f"]["TextWrapped"] = true;
G2L["f"]["BorderSizePixel"] = 0;
G2L["f"]["TextSize"] = 25;
G2L["f"]["TextColor3"] = Color3.fromRGB(255, 0, 0);
G2L["f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f"]["BackgroundTransparency"] = 1;
G2L["f"]["Size"] = UDim2.new(0.10085, 0, 1.06249, 0);
G2L["f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["f"]["Text"] = [[x]];
G2L["f"]["Name"] = [[x]];
G2L["f"]["Position"] = UDim2.new(0.89803, 0, -0.2, 0);


-- StarterGui.plex..main.explorer.name.x.close
G2L["10"] = Instance.new("LocalScript", G2L["f"]);
G2L["10"]["Name"] = [[close]];


-- StarterGui.plex..main.explorer.treeview
G2L["11"] = Instance.new("Frame", G2L["9"]);
G2L["11"]["BorderSizePixel"] = 0;
G2L["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["11"]["Size"] = UDim2.new(0.95593, 0, 0.9668, 0);
G2L["11"]["Position"] = UDim2.new(0.04193, 0, 0.0332, 0);
G2L["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["11"]["Name"] = [[treeview]];
G2L["11"]["BackgroundTransparency"] = 1;


-- StarterGui.plex..main.explorer.treeview.tree
G2L["12"] = Instance.new("ScrollingFrame", G2L["11"]);
G2L["12"]["Active"] = true;
G2L["12"]["BorderSizePixel"] = 0;
G2L["12"]["Name"] = [[tree]];
G2L["12"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["12"]["Size"] = UDim2.new(1.03987, 0, 0.97448, 0);
G2L["12"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0);
G2L["12"]["Position"] = UDim2.new(-0.04386, 0, 0.02552, 0);
G2L["12"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["12"]["ScrollBarThickness"] = 4;
G2L["12"]["BackgroundTransparency"] = 1;


-- StarterGui.plex..main.notepad
G2L["13"] = Instance.new("Frame", G2L["8"]);
G2L["13"]["Visible"] = false;
G2L["13"]["BorderSizePixel"] = 0;
G2L["13"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["13"]["Size"] = UDim2.new(0.33952, 0, 0.53373, 0);
G2L["13"]["Position"] = UDim2.new(0.32973, 0, 0.23253, 0);
G2L["13"]["Name"] = [[notepad]];
G2L["13"]["BackgroundTransparency"] = 0.2;


-- StarterGui.plex..main.notepad.UICorner
G2L["14"] = Instance.new("UICorner", G2L["13"]);
G2L["14"]["CornerRadius"] = UDim.new(0, 2);


-- StarterGui.plex..main.notepad.UIStroke
G2L["15"] = Instance.new("UIStroke", G2L["13"]);
G2L["15"]["Thickness"] = 1.5;
G2L["15"]["Color"] = Color3.fromRGB(28, 43, 54);


-- StarterGui.plex..main.notepad.view
G2L["16"] = Instance.new("Frame", G2L["13"]);
G2L["16"]["BorderSizePixel"] = 0;
G2L["16"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["16"]["Size"] = UDim2.new(0.88406, 0, 0.85434, 0);
G2L["16"]["Position"] = UDim2.new(0.05801, 0, 0.06998, 0);
G2L["16"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["16"]["Name"] = [[view]];
G2L["16"]["BackgroundTransparency"] = 0.5;


-- StarterGui.plex..main.notepad.view.UICorner
G2L["17"] = Instance.new("UICorner", G2L["16"]);



-- StarterGui.plex..main.notepad.view.UIStroke
G2L["18"] = Instance.new("UIStroke", G2L["16"]);
G2L["18"]["Thickness"] = 2;
G2L["18"]["Color"] = Color3.fromRGB(28, 43, 54);


-- StarterGui.plex..main.notepad.view.copy
G2L["19"] = Instance.new("TextButton", G2L["16"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["TextSize"] = 14;
G2L["19"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["19"]["BackgroundTransparency"] = 1;
G2L["19"]["Size"] = UDim2.new(0, 70, 0, 21);
G2L["19"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["19"]["Text"] = [[Copy to clipboard]];
G2L["19"]["Name"] = [[copy]];
G2L["19"]["Position"] = UDim2.new(0.05069, 0, 0, 0);


-- StarterGui.plex..main.notepad.view.save
G2L["1a"] = Instance.new("TextButton", G2L["16"]);
G2L["1a"]["BorderSizePixel"] = 0;
G2L["1a"]["TextSize"] = 14;
G2L["1a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1a"]["BackgroundTransparency"] = 1;
G2L["1a"]["Size"] = UDim2.new(0, 70, 0, 21);
G2L["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1a"]["Text"] = [[Save to file]];
G2L["1a"]["Name"] = [[save]];
G2L["1a"]["Position"] = UDim2.new(0.80052, 0, 0, 0);


-- StarterGui.plex..main.notepad.view.beautify
G2L["1b"] = Instance.new("TextButton", G2L["16"]);
G2L["1b"]["BorderSizePixel"] = 0;
G2L["1b"]["TextSize"] = 14;
G2L["1b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1b"]["BackgroundTransparency"] = 1;
G2L["1b"]["Size"] = UDim2.new(0, 70, 0, 21);
G2L["1b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1b"]["Text"] = [[Beautify]];
G2L["1b"]["Name"] = [[beautify]];
G2L["1b"]["Position"] = UDim2.new(0.56346, 0, 0, 0);


-- StarterGui.plex..main.notepad.view.execute
G2L["1c"] = Instance.new("TextButton", G2L["16"]);
G2L["1c"]["BorderSizePixel"] = 0;
G2L["1c"]["TextSize"] = 14;
G2L["1c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1c"]["BackgroundTransparency"] = 1;
G2L["1c"]["Size"] = UDim2.new(0, 70, 0, 21);
G2L["1c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1c"]["Text"] = [[Execute]];
G2L["1c"]["Name"] = [[execute]];
G2L["1c"]["Position"] = UDim2.new(0.28988, 0, 0, 0);


-- StarterGui.plex..main.notepad.view.scriptview
G2L["1d"] = Instance.new("ScrollingFrame", G2L["16"]);
G2L["1d"]["Active"] = true;
G2L["1d"]["BorderSizePixel"] = 0;
G2L["1d"]["Name"] = [[scriptview]];
G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1d"]["Size"] = UDim2.new(1, 0, 0.93264, 0);
G2L["1d"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1d"]["Position"] = UDim2.new(-0, 0, 0.06736, 0);
G2L["1d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1d"]["ScrollBarThickness"] = 4;
G2L["1d"]["BackgroundTransparency"] = 0.96;


-- StarterGui.plex..main.notepad.top
G2L["1e"] = Instance.new("Frame", G2L["13"]);
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["1e"]["Size"] = UDim2.new(1.00083, 0, 0.04826, 0);
G2L["1e"]["Position"] = UDim2.new(-0.00083, 0, -0.00173, 0);
G2L["1e"]["Name"] = [[top]];
G2L["1e"]["BackgroundTransparency"] = 0.3;


-- StarterGui.plex..main.notepad.top.lablel
G2L["1f"] = Instance.new("TextLabel", G2L["1e"]);
G2L["1f"]["BorderSizePixel"] = 0;
G2L["1f"]["TextSize"] = 14;
G2L["1f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(90, 90, 90);
G2L["1f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1f"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
G2L["1f"]["BackgroundTransparency"] = 1;
G2L["1f"]["Size"] = UDim2.new(0.13178, 0, 1, 0);
G2L["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1f"]["Text"] = [[    Notepad]];
G2L["1f"]["Name"] = [[lablel]];
G2L["1f"]["Position"] = UDim2.new(0.00071, 0, -0, 0);


-- StarterGui.plex..main.notepad.top.x
G2L["20"] = Instance.new("TextButton", G2L["1e"]);
G2L["20"]["TextWrapped"] = true;
G2L["20"]["BorderSizePixel"] = 0;
G2L["20"]["TextSize"] = 25;
G2L["20"]["TextColor3"] = Color3.fromRGB(255, 0, 0);
G2L["20"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["20"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["20"]["BackgroundTransparency"] = 1;
G2L["20"]["Size"] = UDim2.new(0.03633, 0, 1.06249, 0);
G2L["20"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["20"]["Text"] = [[x]];
G2L["20"]["Name"] = [[x]];
G2L["20"]["Position"] = UDim2.new(0.96255, 0, -0.2, 0);


-- StarterGui.plex..main.notepad.top.x.hide
G2L["21"] = Instance.new("LocalScript", G2L["20"]);
G2L["21"]["Name"] = [[hide]];


-- StarterGui.plex..main.notepad.top.drag
G2L["22"] = Instance.new("LocalScript", G2L["1e"]);
G2L["22"]["Name"] = [[drag]];


-- StarterGui.plex..main.properties
G2L["23"] = Instance.new("Frame", G2L["8"]);
G2L["23"]["BorderSizePixel"] = 3;
G2L["23"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["23"]["Size"] = UDim2.new(0.13422, 0, 0.23373, 0);
G2L["23"]["Position"] = UDim2.new(0.86183, 0, 0.76627, 0);
G2L["23"]["Name"] = [[properties]];
G2L["23"]["BackgroundTransparency"] = 0.2;


-- StarterGui.plex..main.properties.container
G2L["24"] = Instance.new("ScrollingFrame", G2L["23"]);
G2L["24"]["Active"] = true;
G2L["24"]["BorderSizePixel"] = 0;
G2L["24"]["Name"] = [[container]];
G2L["24"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["24"]["Size"] = UDim2.new(0.99786, 0, 0.88208, 0);
G2L["24"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0);
G2L["24"]["Position"] = UDim2.new(0, 0, 0.11792, 0);
G2L["24"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["24"]["ScrollBarThickness"] = 4;
G2L["24"]["BackgroundTransparency"] = 1;


-- StarterGui.plex..main.properties.search
G2L["25"] = Instance.new("Frame", G2L["23"]);
G2L["25"]["BorderSizePixel"] = 0;
G2L["25"]["BackgroundColor3"] = Color3.fromRGB(53, 53, 53);
G2L["25"]["Size"] = UDim2.new(1.00502, 0, 0.14859, 0);
G2L["25"]["Position"] = UDim2.new(-0.00623, 0, -0.00988, 0);
G2L["25"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["25"]["Name"] = [[search]];


-- StarterGui.plex..main.properties.search.input
G2L["26"] = Instance.new("TextBox", G2L["25"]);
G2L["26"]["CursorPosition"] = -1;
G2L["26"]["Name"] = [[input]];
G2L["26"]["PlaceholderColor3"] = Color3.fromRGB(101, 101, 101);
G2L["26"]["TextWrapped"] = true;
G2L["26"]["TextSize"] = 14;
G2L["26"]["TextColor3"] = Color3.fromRGB(215, 215, 215);
G2L["26"]["TextScaled"] = true;
G2L["26"]["BackgroundColor3"] = Color3.fromRGB(53, 53, 53);
G2L["26"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["26"]["PlaceholderText"] = [[Search properties]];
G2L["26"]["Size"] = UDim2.new(0.91721, 0, -0.78, 0);
G2L["26"]["Position"] = UDim2.new(0.04016, 0, 0.86654, 0);
G2L["26"]["Text"] = [[]];
G2L["26"]["BackgroundTransparency"] = 0.6;


-- StarterGui.plex..main.properties.name
G2L["27"] = Instance.new("Frame", G2L["23"]);
G2L["27"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["27"]["Size"] = UDim2.new(1.00502, 0, 0.14316, 0);
G2L["27"]["Position"] = UDim2.new(-0.00623, 0, -0.13425, 0);
G2L["27"]["Name"] = [[name]];


-- StarterGui.plex..main.properties.name.lablel
G2L["28"] = Instance.new("TextLabel", G2L["27"]);
G2L["28"]["BorderSizePixel"] = 0;
G2L["28"]["TextSize"] = 14;
G2L["28"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["28"]["BackgroundColor3"] = Color3.fromRGB(90, 90, 90);
G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["28"]["TextColor3"] = Color3.fromRGB(101, 101, 101);
G2L["28"]["BackgroundTransparency"] = 0.6;
G2L["28"]["Size"] = UDim2.new(1.00779, 0, -1.0005, 0);
G2L["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["28"]["Text"] = [[    Properties]];
G2L["28"]["Name"] = [[lablel]];
G2L["28"]["Position"] = UDim2.new(0, 0, 1, 0);


-- StarterGui.plex..main.properties.name.x
G2L["29"] = Instance.new("TextButton", G2L["27"]);
G2L["29"]["TextWrapped"] = true;
G2L["29"]["BorderSizePixel"] = 0;
G2L["29"]["TextSize"] = 25;
G2L["29"]["TextColor3"] = Color3.fromRGB(255, 0, 0);
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["29"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["29"]["BackgroundTransparency"] = 1;
G2L["29"]["Size"] = UDim2.new(0.10085, 0, 1.06249, 0);
G2L["29"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["29"]["Text"] = [[x]];
G2L["29"]["Name"] = [[x]];
G2L["29"]["Position"] = UDim2.new(0.89803, 0, -0.2, 0);


-- StarterGui.plex..main.properties.name.x.close
G2L["2a"] = Instance.new("LocalScript", G2L["29"]);
G2L["2a"]["Name"] = [[close]];


-- StarterGui.plex..main.properties.left
G2L["2b"] = Instance.new("Frame", G2L["23"]);
G2L["2b"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
G2L["2b"]["Size"] = UDim2.new(0.01894, 0, 1.13422, 0);
G2L["2b"]["Position"] = UDim2.new(-0.02516, 0, -0.13425, 0);
G2L["2b"]["Name"] = [[left]];
G2L["2b"]["BackgroundTransparency"] = 0.1;


-- StarterGui.plex..main.check
G2L["2c"] = Instance.new("LocalScript", G2L["8"]);
G2L["2c"]["Name"] = [[check]];


-- Require G2L wrapper
local G2L_REQUIRE = require;
local G2L_MODULES = {};
local function require(Module:ModuleScript)
    local ModuleState = G2L_MODULES[Module];
    if ModuleState then
        if not ModuleState.Required then
            ModuleState.Required = true;
            ModuleState.Value = ModuleState.Closure();
        end
        return ModuleState.Value;
    end;
    return G2L_REQUIRE(Module);
end

G2L_MODULES[G2L["4"]] = {
Closure = function()
    local script = G2L["4"];local decompiler = {}

function decompiler.process(scriptInstance, fallbackOption)
	if not scriptInstance or not (scriptInstance:IsA("LocalScript") or scriptInstance:IsA("ModuleScript")) then
		return "-- Target is not a decompilable Lua Container script."
	end

	local success, result = pcall(function()
		if decompile then
			return decompile(scriptInstance)
		elseif getscriptbytecode then
			return string.format("-- [Fallback Decompiler Enabled: %s]\n-- Direct source extraction unavailable. Bytecode fetched securely.", fallbackOption or "Konstant")
		else
			return "-- Current execution setup lacks decompiler API integration support."
		end
	end)

	return success and result or ("-- Extraction process faulted: " .. tostring(result))
end

function decompiler.save(scriptInstance, fallbackOption)
	local source = decompiler.process(scriptInstance, fallbackOption)
	local safeName = scriptInstance.Name:gsub("[^%w%s-_]", "")
	local path = string.format("%s_%s_Dump.txt", safeName, scriptInstance.ClassName)

	local written, err = pcall(function()
		if writefile then
			writefile(path, source)
			return true
		end
		return false
	end)

	return written, path, err
end

function decompiler.highlight(source)
	local keywordColors = {
		["local"] = "#f86d73", ["function"] = "#f86d73", ["return"] = "#f86d73",
		["if"] = "#f86d73", ["then"] = "#f86d73", ["else"] = "#f86d73", ["elseif"] = "#f86d73",
		["end"] = "#f86d73", ["while"] = "#f86d73", ["do"] = "#f86d73", ["for"] = "#f86d73",
		["true"] = "#ffc600", ["false"] = "#ffc600", ["nil"] = "#ffc600"
	}

	local lines = string.split(source, "\n")
	local parsed = {}

	for _, line in ipairs(lines) do
		local outputLine = line:gsub("<", "&lt;"):gsub(">", "&gt;")

		for word, hexColor in pairs(keywordColors) do
			outputLine = outputLine:gsub("%f[%w]"..word.."%f[%W]", string.format('<font color="%s">%s</font>', hexColor, word))
		end

		if outputLine:match("%-%-") then
			outputLine = outputLine:gsub("(%-%-.*)", '<font color="#666666">%1</font>')
		end

		table.insert(parsed, outputLine)
	end

	return table.concat(parsed, "\n")
end

return decompiler
end;
};
G2L_MODULES[G2L["5"]] = {
Closure = function()
    local script = G2L["5"];local scanner = {}
local nodes = {}
local idCounter = 0

-- Priority mapping for typical object list hierarchy display order
local explorerOrders = {
	Workspace = 1,
	Players = 2,
	Lighting = 3,
	ReplicatedFirst = 4,
	ReplicatedStorage = 5,
	ServerScriptService = 6,
	ServerStorage = 7,
	StarterGui = 8,
	StarterPack = 9,
	StarterPlayer = 10,
	SoundService = 11,
	Chat = 12,
	LocalizationService = 13,
	TestService = 14
}

function scanner.createNode(instance, parentNode)
	if nodes[instance] then return nodes[instance] end

	idCounter = (idCounter + 0.001) % 99999999
	local node = {
		Obj = instance,
		Class = instance.ClassName,
		Parent = parentNode,
		Id = idCounter,
		Sorted = false
	}

	nodes[instance] = node
	return node
end

function scanner.getNode(instance)
	return nodes[instance]
end

function scanner.removeNode(instance)
	nodes[instance] = nil
end

function scanner.nodeSorter(a, b)
	if not a.Obj or not b.Obj then return false end

	local aOrder = explorerOrders[a.Class] or 9999
	local bOrder = explorerOrders[b.Class] or 9999

	if aOrder ~= bOrder then
		return aOrder < bOrder
	else
		local aName, bName = tostring(a.Obj), tostring(b.Obj)
		if aName ~= bName then
			return aName < bName
		else
			return a.Id < b.Id
		end
	end
end

function scanner.search(query, rootInstance)
	local queryLower = string.lower(query)
	local matches = {}

	local function traverse(instance)
		pcall(function()
			if string.find(string.lower(instance.Name), queryLower) then
				table.insert(matches, scanner.createNode(instance))
			end
			for _, child in ipairs(instance:GetChildren()) do
				traverse(child)
			end
		end)
	end

	traverse(rootInstance or game)
	return matches
end

return scanner
end;
};
G2L_MODULES[G2L["6"]] = {
Closure = function()
    local script = G2L["6"];local uicontroller = {}

local expanded = {}
local visibleTree = {}

uicontroller.EntryIndent = 20 -- Pixels per depth level

-- Embedded Core Class Map Indexes matching Dex Sprite Sheets
local ClassIconIndex = {
	Part = 1, Model = 2, Folder = 3, Script = 4, LocalScript = 5, ModuleScript = 6,
	Workspace = 302, WedgePart = 297, Weld = 298, Decal = 7, Sound = 8, Lighting = 9
}

function uicontroller.init(scrollingFrame, template)
	uicontroller.Container = scrollingFrame
	uicontroller.Template = template
end

function uicontroller.toggleExpand(node, scannerModule, sortingEnabled)
	expanded[node] = not expanded[node]
	uicontroller.refresh(node, scannerModule, sortingEnabled)
end

function uicontroller.buildVisibleTree(rootInstance, scannerModule, sortingEnabled)
	table.clear(visibleTree)

	local function recurse(instance, parentNode)
		local node = scannerModule.createNode(instance, parentNode)
		table.insert(visibleTree, node)

		if expanded[node] then
			local children = instance:GetChildren()
			local childNodes = {}

			for _, child in ipairs(children) do
				local childNode = scannerModule.createNode(child, node)
				table.insert(childNodes, childNode)
			end

			if sortingEnabled then
				table.sort(childNodes, scannerModule.nodeSorter)
			end

			for _, childNode in ipairs(childNodes) do
				recurse(childNode.Obj, node)
			end
		end
	end

	recurse(rootInstance)
	return visibleTree
end

function uicontroller.applyIcon(imageLabel, className)
	local index = ClassIconIndex[className] or 0
	imageLabel.Image = "rbxassetid://5642383285" -- Standard studio assets fallback

	-- Calculate sprite map offset offsets 16x16 pixels
	local x = (index % 32) * 16
	local y = math.floor(index / 32) * 16
	imageLabel.ImageRectOffset = Vector2.new(x, y)
	imageLabel.ImageRectSize = Vector2.new(16, 16)
end

function uicontroller.render(scannerModule, sortingEnabled)
	local container = uicontroller.Container
	if not container then return end

	-- Purge pre-existing element graphics smoothly
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end

	container.CanvasSize = UDim2.new(0, 0, 0, #visibleTree * 20)

	for i, node in ipairs(visibleTree) do
		local entry = uicontroller.Template:Clone()
		entry.Name = "Entry_" .. node.Obj.Name
		entry.Position = UDim2.new(0, 0, 0, (i - 1) * 20)
		entry.Visible = true

		-- Dynamic level tracking depth
		local depth = 0
		local temp = node.Parent
		while temp do
			depth = depth + 1
			temp = temp.Parent
		end

		local indentFrame = entry:FindFirstChild("Indent") or entry
		indentFrame.Position = UDim2.new(0, depth * uicontroller.EntryIndent, 0, 0)
		indentFrame.Size = UDim2.new(1, -(depth * uicontroller.EntryIndent), 1, 0)

		local textLabel = indentFrame:FindFirstChild("EntryName") or entry:FindFirstChildOfClass("TextLabel")
		if textLabel then textLabel.Text = node.Obj.Name end

		local iconLabel = indentFrame:FindFirstChild("Icon") or entry:FindFirstChildOfClass("ImageLabel")
		if iconLabel then uicontroller.applyIcon(iconLabel, node.Class) end

		local expandBtn = indentFrame:FindFirstChild("Expand")
		if expandBtn then
			local validChildren = #node.Obj:GetChildren() > 0
			expandBtn.Visible = validChildren
			if validChildren then
				expandBtn.Text = expanded[node] and "▼" or "►"
				expandBtn.MouseButton1Click:Connect(function()
					uicontroller.toggleExpand(node, scannerModule, sortingEnabled)
				end)
			end
		end

		entry.Parent = container
	end
end

function uicontroller.refresh(rootInstance, scannerModule, sortingEnabled)
	uicontroller.buildVisibleTree(rootInstance, scannerModule, sortingEnabled)
	uicontroller.render(scannerModule, sortingEnabled)
end

return uicontroller
end;
};
G2L_MODULES[G2L["7"]] = {
Closure = function()
    local script = G2L["7"];local propcontroller = {}

local defaults = {
	string = "", number = 0, boolean = false,
	Vector3 = Vector3.new(0,0,0), CFrame = CFrame.new(), Color3 = Color3.fromRGB(255,255,255)
}

function propcontroller.get(instance)
	if not instance then return {} end
	local entries = {}

	local queryMap = {"Name", "ClassName", "Parent", "Archivable"}

	-- Specialized object property map injection lists
	if instance:IsA("BasePart") then
		local partProps = {"Size", "Position", "Anchored", "CanCollide", "Transparency", "Color", "Material"}
		for _, p in ipairs(partProps) do table.insert(queryMap, p) end
	elseif instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		local uiProps = {"Text", "TextColor3", "TextSize", "Font", "TextScaled"}
		for _, p in ipairs(uiProps) do table.insert(queryMap, p) end
	elseif instance:IsA("Sound") then
		local audioProps = {"SoundId", "Volume", "Pitch", "Playing", "Looped"}
		for _, p in ipairs(audioProps) do table.insert(queryMap, p) end
	end

	for _, name in ipairs(queryMap) do
		local ok, val = pcall(function() return instance[name] end)
		if ok then
			table.insert(entries, {
				Name = name,
				Value = val,
				Type = typeof(val)
			})
		end
	end

	return entries
end

function propcontroller.set(instance, property, value)
	if not instance then return false, "Null target referenced" end
	local ok, err = pcall(function()
		instance[property] = value
	end)
	return ok, err
end

function propcontroller.reset(instance, property)
	local list = propcontroller.get(instance)
	for _, item in ipairs(list) do
		if item.Name == property then
			local fallback = defaults[item.Type]
			if fallback ~= nil then
				return propcontroller.set(instance, property, fallback)
			end
		end
	end
	return false, "No matching primitive fallback logic resolved."
end

return propcontroller
end;
};
-- StarterGui.plex..core
local function C_2()
local script = G2L["2"];
	local sgui = script.Parent
	local modules = sgui:WaitForChild("Modules")
	
	local scanner = require(modules:WaitForChild("scanner"))
	local controller = require(modules:WaitForChild("uicontroller"))
	local decompiler = require(modules:WaitForChild("decompiler"))
	local propertiesCtrl = require(modules:WaitForChild("propcontroller"))
	
	local mfrm = sgui:WaitForChild("main")
	local tree = mfrm:WaitForChild("explorer"):WaitForChild("treeview"):WaitForChild("tree")
	local search = mfrm:WaitForChild("explorer"):WaitForChild("search"):WaitForChild("input")
	
	local propScrollFrame = mfrm:WaitForChild("properties"):WaitForChild("container")
	local propSearch = mfrm:WaitForChild("properties"):WaitForChild("search"):WaitForChild("input")
	
	local notepad = mfrm:WaitForChild("notepad")
	local scriptView = notepad:WaitForChild("view"):WaitForChild("scriptview")
	local copyBtn = notepad:WaitForChild("view"):WaitForChild("copy")
	local saveBtn = notepad:WaitForChild("view"):WaitForChild("save")
	local beautifyBtn = notepad:WaitForChild("view"):WaitForChild("beautify")
	local executeBtn = notepad:WaitForChild("view"):WaitForChild("execute")
	
	local selectedInstance = nil
	local activeDecompiledScript = nil
	local searchDebounceToken = 0
	local propDebounceToken = 0
	
	scriptView.AutomaticCanvasSize = Enum.AutomaticSize.XY
	scriptView.CanvasSize = UDim2.new(0, 0, 0, 0)
	
	-- ==========================================
	-- DEX++ INTEGRATED CLASS ICON MAP SYSTEM
	-- ==========================================
	local ClassNameToIconIndex = {
		["Instance"] = 0, ["Part"] = 1, ["Model"] = 10, ["Folder"] = 23, 
		["Script"] = 24, ["LocalScript"] = 25, ["ModuleScript"] = 26,
		["Workspace"] = 29, ["Players"] = 30, ["Player"] = 31, ["Lighting"] = 32, 
		["ReplicatedStorage"] = 51, ["ServerScriptService"] = 52, ["ServerStorage"] = 53, 
		["StarterGui"] = 54, ["StarterPack"] = 55, ["StarterPlayer"] = 56, 
		["Sound"] = 22, ["Tool"] = 17, ["Humanoid"] = 12, ["Configuration"] = 58,
		["RemoteEvent"] = 61, ["RemoteFunction"] = 62, ["BindableEvent"] = 63, ["BindableFunction"] = 64,
		["ScreenGui"] = 47, ["Frame"] = 48, ["TextLabel"] = 49, ["TextButton"] = 50, ["TextBox"] = 51,
		["ImageLabel"] = 52, ["ImageButton"] = 53, ["ScrollingFrame"] = 54, ["UIListLayout"] = 27,
		["UIGridLayout"] = 27, ["UIPadding"] = 27, ["UIStroke"] = 27, ["UICorner"] = 27
	}
	
	local function GetIconRectOffset(className)
		local index = ClassNameToIconIndex[className] or ClassNameToIconIndex["Instance"]
		local iconsPerRow = 16
		local iconSize = 16
		local col = index % iconsPerRow
		local row = math.floor(index / iconsPerRow)
		return Vector2.new(col * iconSize, row * iconSize)
	end
	
	-- ==========================================
	-- UI INITIALIZATION & TEXTBOX HOOKS
	-- ==========================================
	local lineNumbers = scriptView:FindFirstChild("LineNumbers") or Instance.new("TextLabel")
	if not lineNumbers.Parent then
		lineNumbers.Name = "LineNumbers"
		lineNumbers.Size = UDim2.new(0, 35, 1, 0)
		lineNumbers.Position = UDim2.new(0, 5, 0, 0)
		lineNumbers.BackgroundTransparency = 1
		lineNumbers.Font = Enum.Font.RobotoMono
		lineNumbers.TextSize = 13
		lineNumbers.TextColor3 = Color3.fromRGB(110, 110, 110)
		lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
		lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
		lineNumbers.Text = "1"
		lineNumbers.Parent = scriptView
	end
	
	local codeLabel = scriptView:FindFirstChild("CodeLabel") or Instance.new("TextLabel")
	if not codeLabel.Parent then
		codeLabel.Name = "CodeLabel"
		codeLabel.Size = UDim2.new(1, -55, 1, 0)
		codeLabel.Position = UDim2.new(0, 45, 0, 0)
		codeLabel.BackgroundTransparency = 1
		codeLabel.Font = Enum.Font.RobotoMono
		codeLabel.TextSize = 13
		codeLabel.RichText = true
		codeLabel.TextXAlignment = Enum.TextXAlignment.Left
		codeLabel.TextYAlignment = Enum.TextYAlignment.Top
		codeLabel.Text = ""
		codeLabel.Parent = scriptView
	end
	
	local codeTextBox = scriptView:FindFirstChild("CodeTextBox") or Instance.new("TextBox")
	if not codeTextBox.Parent then
		codeTextBox.Name = "CodeTextBox"
		codeTextBox.Size = UDim2.new(1, -55, 1, 0)
		codeTextBox.Position = UDim2.new(0, 45, 0, 0)
		codeTextBox.BackgroundTransparency = 1
		codeTextBox.TextTransparency = 0.99 
		codeTextBox.ClearTextOnFocus = false
		codeTextBox.MultiLine = true
		codeTextBox.TextEditable = false 
		codeTextBox.Font = Enum.Font.RobotoMono
		codeTextBox.TextSize = 13
		codeTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		codeTextBox.TextXAlignment = Enum.TextXAlignment.Left
		codeTextBox.TextYAlignment = Enum.TextYAlignment.Top
		codeTextBox.Text = "-- Double-click a script to begin"
		codeTextBox.Parent = scriptView
	end
	
	local HighlightGroups = {
		Keywords = {
			["local"] = true, ["function"] = true, ["return"] = true, ["if"] = true, 
			["then"] = true, ["else"] = true, ["elseif"] = true, ["end"] = true, 
			["for"] = true, ["in"] = true, ["do"] = true, ["while"] = true, 
			["repeat"] = true, ["until"] = true, ["break"] = true, ["continue"] = true,
			["and"] = true, ["or"] = true, ["not"] = true, ["type"] = true, ["export"] = true
		},
		Globals = {
			["game"] = true, ["workspace"] = true, ["script"] = true, ["shared"] = true, 
			["_G"] = true, ["_VERSION"] = true, ["plugin"] = true, ["getgenv"] = true, 
			["getrenv"] = true, ["getreg"] = true, ["getgc"] = true, ["getloadedmodules"] = true
		},
		Builtins = {
			["print"] = true, ["warn"] = true, ["error"] = true, ["assert"] = true, 
			["typeof"] = true, ["type"] = true, ["require"] = true, ["pcall"] = true, 
			["xpcall"] = true, ["tostring"] = true, ["tonumber"] = true, ["pairs"] = true, 
			["ipairs"] = true, ["next"] = true, ["select"] = true, ["tick"] = true, ["time"] = true,
			["delay"] = true, ["spawn"] = true, ["wait"] = true
		},
		Libraries = {
			["math"] = true, ["table"] = true, ["string"] = true, ["task"] = true, 
			["debug"] = true, ["os"] = true, ["coroutine"] = true, ["bit32"] = true, 
			["buffer"] = true, ["utf8"] = true
		},
		Datatypes = {
			["Vector3"] = true, ["Vector2"] = true, ["UDim2"] = true, ["UDim"] = true, 
			["Color3"] = true, ["CFrame"] = true, ["Instance"] = true, ["Enum"] = true, 
			["Rect"] = true, ["Region3"] = true, ["TweenInfo"] = true, ["Axes"] = true, ["Faces"] = true
		}
	}
	
	local function ApplyHighlighting(source)
		local clean = source:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		local literalMap = {}
		local literalCounter = 0
	
		local function storeLiteral(content, colorCode)
			literalCounter = literalCounter + 1
			local n = literalCounter
			local alphabetTag = ""
			while n > 0 do
				local rem = (n - 1) % 26
				alphabetTag = string.char(65 + rem) .. alphabetTag
				n = math.floor((n - 1) / 26)
			end
			if alphabetTag == "" then alphabetTag = "A" end
	
			local placeholder = "___LITERAL" .. alphabetTag .. "___"
			literalMap[placeholder] = '<font color="' .. colorCode .. '">' .. content .. '</font>'
			return placeholder
		end
	
		clean = clean:gsub('("[^"\n]*")', function(c) return storeLiteral(c, "rgb(224, 178, 110)") end)
		clean = clean:gsub("('[^'\n]*')", function(c) return storeLiteral(c, "rgb(224, 178, 110)") end)
		clean = clean:gsub("(%[%[[^%]]*%]%])", function(c) return storeLiteral(c, "rgb(224, 178, 110)") end)
		clean = clean:gsub("(%-%-[^\n]*)", function(c) return storeLiteral(c, "rgb(100, 180, 100)") end)
	
		clean = clean:gsub("([%a_][%w_]*)", function(word)
			if HighlightGroups.Keywords[word] then
				return '<font color="rgb(248, 109, 124)">' .. word .. '</font>'
			elseif HighlightGroups.Globals[word] then
				return '<font color="rgb(132, 214, 243)">' .. word .. '</font>'
			elseif HighlightGroups.Builtins[word] then
				return '<font color="rgb(107, 190, 255)">' .. word .. '</font>'
			elseif HighlightGroups.Libraries[word] or HighlightGroups.Datatypes[word] then
				return '<font color="rgb(236, 191, 123)">' .. word .. '</font>'
			elseif word == "self" then
				return '<font color="rgb(217, 140, 235)">' .. word .. '</font>'
			elseif word == "true" or word == "false" or word == "nil" then
				return '<font color="rgb(247, 140, 108)">' .. word .. '</font>'
			end
			return word
		end)
	
		clean = clean:gsub("%f[%w](%d+)%f[%W]", '<font color="rgb(180, 150, 250)">%1</font>')
	
		for placeholder, htmlReplacement in pairs(literalMap) do
			clean = clean:gsub(placeholder, htmlReplacement)
		end
	
		return clean
	end
	
	local function UpdateCodeView()
		local text = codeTextBox.Text
		local _, lineCount = text:gsub("\n", "\n")
		lineCount = lineCount + 1
	
		local gutterLines = {}
		for i = 1, lineCount do table.insert(gutterLines, tostring(i)) end
		lineNumbers.Text = table.concat(gutterLines, "\n")
	
		codeLabel.Text = ApplyHighlighting(text)
	
		local maxWidth = math.max(scriptView.AbsoluteSize.X - 60, codeTextBox.TextBounds.X + 50)
		local maxHeight = math.max(scriptView.AbsoluteSize.Y - 10, codeTextBox.TextBounds.Y + 40)
		local frameSize = UDim2.new(0, maxWidth, 0, maxHeight)
	
		codeTextBox.Size = frameSize
		codeLabel.Size = frameSize
		lineNumbers.Size = UDim2.new(0, 35, 0, maxHeight)
	end
	
	codeTextBox:GetPropertyChangedSignal("Text"):Connect(UpdateCodeView)
	codeTextBox:GetPropertyChangedSignal("TextBounds"):Connect(UpdateCodeView)
	scriptView:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCodeView)
	
	local listLayout = tree:FindFirstChildOfClass("UIListLayout")
	if not listLayout then
		listLayout = Instance.new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 2)
		listLayout.Parent = tree
	end
	tree.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tree.CanvasSize = UDim2.new(0, 0, 0, 0)
	
	-- ==========================================
	-- DEX++ STYLED HIGH-FIDELITY TREE VIEW BUILDER
	-- ==========================================
	local function CreateDexNodeElement(parentFrame, nodeData, orderIndex, isSelected, onClick, onDoubleClick)
		local instance = nodeData.Instance
		local depth = nodeData.Depth or 0
		local hasChildren = nodeData.HasChildren
		local isExpanded = scanner.ExpandedNodes[instance] or false
	
		local entry = Instance.new("TextButton")
		entry.Name = "Entry_" .. tostring(orderIndex)
		entry.Size = UDim2.new(1, 0, 0, 22)
		entry.BackgroundTransparency = isSelected and 0.85 or 1
		entry.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
		entry.BorderSizePixel = 0
		entry.Text = ""
		entry.LayoutOrder = orderIndex
		entry.Parent = parentFrame
	
		local indent = Instance.new("Frame")
		indent.Name = "Indent"
		indent.Size = UDim2.new(1, -(depth * 16), 1, 0)
		indent.Position = UDim2.new(0, depth * 16, 0, 0)
		indent.BackgroundTransparency = 1
		indent.Parent = entry
	
		if hasChildren then
			local expand = Instance.new("TextButton")
			expand.Name = "Expand"
			expand.Size = UDim2.new(0, 16, 0, 22)
			expand.Position = UDim2.new(0, 0, 0, 0)
			expand.BackgroundTransparency = 1
			expand.Font = Enum.Font.SourceSansBold
			expand.TextSize = 10
			expand.TextColor3 = Color3.fromRGB(180, 180, 180)
			expand.Text = isExpanded and "▼" or "▶"
			expand.Parent = indent
	
			expand.MouseButton1Click:Connect(function()
				scanner.ExpandedNodes[instance] = not scanner.ExpandedNodes[instance]
				onClick(instance, entry)
			end)
		end
	
		local icon = Instance.new("ImageLabel")
		icon.Name = "ClassIcon"
		icon.Size = UDim2.new(0, 16, 0, 16)
		icon.Position = UDim2.new(0, 18, 0, 3)
		icon.BackgroundTransparency = 1
		icon.Image = "rbxassetid://5642383285" 
		icon.ImageRectSize = Vector2.new(16, 16)
		icon.ImageRectOffset = GetIconRectOffset(instance.ClassName)
		icon.Parent = indent
	
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "EntryName"
		nameLabel.Size = UDim2.new(1, -40, 1, 0)
		nameLabel.Position = UDim2.new(0, 38, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = instance.Name
		nameLabel.Parent = indent
	
		entry.MouseButton1Click:Connect(function()
			onClick(instance, entry)
		end)
	
		local lastClick = 0
		entry.MouseButton1Down:Connect(function()
			local now = tick()
			if now - lastClick < 0.35 then
				onDoubleClick(instance)
			end
			lastClick = now
		end)
	end
	
	local function ForceDecompile(instance)
		local success, code = pcall(function() return decompiler.DecompileScript(instance) end)
		if success and code and code ~= "" and not code:find("Failed") then return code end
	
		local envDecompile = getgenv and (getgenv().decompile or getgenv().DecompileScript) or decompile
		if typeof(envDecompile) == "function" then
			local ok, res = pcall(envDecompile, instance)
			if ok and res then return res end
		end
	
		if typeof(getscriptbytecode) == "function" then
			local bcSuccess, bytecode = pcall(getscriptbytecode, instance)
			if bcSuccess then
				local requestFunc = (syn and syn.request) or (http and http.request) or request
				if typeof(requestFunc) == "function" then
					local reqSuccess, response = pcall(requestFunc, {
						Url = "https://konstant.api.lovrewe.com/konstant/decompile",
						Method = "POST",
						Headers = { ["Content-Type"] = "text/plain" },
						Body = bytecode
					})
					if reqSuccess and response.StatusCode == 200 then return response.Body end
				end
			end
		end
		return "-- [Error]: All native decompiler pipelines exhausted.\n-- Fallback to Konstant v3.1 Web API failed."
	end
	
	local function RenderTree()
		for _, child in ipairs(tree:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
	
		local nodes = scanner.FlattenHierarchy(search.Text)
	
		for index, nodeData in ipairs(nodes) do
			local isCurrentSelection = (selectedInstance == nodeData.Instance)
	
			CreateDexNodeElement(
				tree,
				nodeData,
				index,
				isCurrentSelection,
				function(instance, button)
					selectedInstance = instance
					RenderTree()
					propertiesCtrl.RenderProperties(propScrollFrame, instance, propSearch.Text)
				end,
				function(instance)
					if instance:IsA("LuaSourceContainer") then
						notepad.Visible = true
						activeDecompiledScript = instance
						codeTextBox.Text = "-- Decompiling " .. instance.Name .. "..."
						task.spawn(function()
							local code = ForceDecompile(instance)
							if activeDecompiledScript == instance then codeTextBox.Text = code end
						end)
					end
				end
			)
		end
	end
	
	beautifyBtn.MouseButton1Click:Connect(function()
		local textToProcess = codeTextBox.Text
		if textToProcess == "" or textToProcess:find("Decompiling") then return end
	
		beautifyBtn.Text = "Beautifying..."
		task.spawn(function()
			local requestFunc = (syn and syn.request) or (http and http.request) or request
			if typeof(requestFunc) == "function" then
				local success, response = pcall(requestFunc, {
					Url = "https://luau-beautifier.api.lovrewe.com/beautify",
					Method = "POST",
					Headers = { ["Content-Type"] = "application/json" },
					Body = game:GetService("HttpService"):JSONEncode({
						source = textToProcess,
						options = { renameVariables = true, indentSpaces = 4 }
					})
				})
	
				if success and response.StatusCode == 200 then
					local decodeSuccess, data = pcall(function() return game:GetService("HttpService"):JSONDecode(response.Body) end)
					if decodeSuccess and data.beautified then
						codeTextBox.Text = data.beautified
						beautifyBtn.Text = "Beautify"
						return
					end
				end
			end
	
			local cleaned = textToProcess:gsub("\n\n\n+", "\n\n")
			cleaned = cleaned:gsub("([%s,])v(%d+)([%s,=%.%(%):])", "%1var_%2%3")
			cleaned = cleaned:gsub("([%s,])u(%d+)([%s,=%.%(%):])", "%1upvalue_%2%3")
			codeTextBox.Text = "-- [Local Fallback Beautify Setup]\n" .. cleaned
			beautifyBtn.Text = "Beautify"
		end)
	end)
	
	executeBtn.MouseButton1Click:Connect(function()
		local run, err = loadstring(codeTextBox.Text)
		if run then task.spawn(pcall, run) else print("[Execution Compile Error]:", err) end
	end)
	
	copyBtn.MouseButton1Click:Connect(function()
		if typeof(setclipboard) == "function" then 
			setclipboard(codeTextBox.Text) 
			local old = copyBtn.Text; copyBtn.Text = "Copied!"; task.wait(1); copyBtn.Text = old
		end
	end)
	
	saveBtn.MouseButton1Click:Connect(function()
		if activeDecompiledScript and typeof(writefile) == "function" then
			pcall(function() writefile(activeDecompiledScript.Name:gsub("[%\\%/%:%*%?%\"%<%%>%|]", "_") .. ".lua", codeTextBox.Text) end)
			local old = saveBtn.Text; saveBtn.Text = "Saved File!"; task.wait(1); saveBtn.Text = old
		end
	end)
	
	search:GetPropertyChangedSignal("Text"):Connect(function()
		local activeToken = searchDebounceToken + 1; searchDebounceToken = activeToken
		task.wait(0.25)
		if activeToken == searchDebounceToken then RenderTree() end
	end)
	
	task.spawn(RenderTree)
	UpdateCodeView()
end;
task.spawn(C_2);
-- StarterGui.plex..main.explorer.name.x.close
local function C_10()
local script = G2L["10"];
	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Parent:Destroy()
	end)
end;
task.spawn(C_10);
-- StarterGui.plex..main.notepad.top.x.hide
local function C_21()
local script = G2L["21"];
	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Parent.Visible = false
	end)
end;
task.spawn(C_21);
-- StarterGui.plex..main.notepad.top.drag
local function C_22()
local script = G2L["22"];
	local UserInputService = game:GetService("UserInputService")
	
	local handle = script.Parent
	local frame = handle.Parent
	
	local dragging = false
	local dragInput
	local dragStart
	local startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
	
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end;
task.spawn(C_22);
-- StarterGui.plex..main.properties.name.x.close
local function C_2a()
local script = G2L["2a"];
	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Parent:Destroy()
	end)
end;
task.spawn(C_2a);
-- StarterGui.plex..main.check
local function C_2c()
local script = G2L["2c"];
	if not script.Parent.explorer and not script.Parent.properties then
		script.Parent.Parent:Destroy()
	end
end;
task.spawn(C_2c);

return G2L["1"], require;
