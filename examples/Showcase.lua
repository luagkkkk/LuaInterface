-- Load LuaInterface.lua in a trusted client context, then run this showcase.
local LuaInterface = assert(_G.LuaInterface, "Run LuaInterface.lua in the client first")

local Window = LuaInterface:CreateWindow({
    Title = "LuaInterface Showcase",
    Author = "LuaInterface 1.1.1-beta",
    Icon = "boxes",
    Theme = "Graphite",
    Acrylic = false, -- turn on with the Acrylic tab after checking device performance
    AutoShow = true,
    KeepDefaultTabs = false,
    Resizable = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(900, 620),
})

local general = Window:Section({ Title = "EXAMPLES" })
local controls = general:Tab({ Title = "Elements", Desc = "Control inventory", Icon = "sliders" })
local layout = general:Tab({ Title = "Layout", Desc = "Group and stack layout", Icon = "grid" })
local appearance = Window:Section({ Title = "DISPLAY" })
local visual = appearance:Tab({ Title = "Themes & Shapes", Icon = "palette" })
local keyTab = appearance:Tab({ Title = "Icons & Keys", Icon = "keyboard" })
local noticeTab = appearance:Tab({ Title = "Notifications", Icon = "bell" })
local acrylicTab = appearance:Tab({ Title = "Acrylic", Icon = "shield" })
local configTab = appearance:Tab({ Title = "SaveManager", Icon = "save" })

local inputGroup = controls:Group({
    Title = "Common controls",
    Desc = "Callbacks and local element state",
    Icon = "settings",
})
inputGroup:Paragraph({
    Title = "Component examples",
    Desc = "Buttons, inputs, values, and callbacks in one place.",
})
inputGroup:Button({
    Title = "Run callback",
    Desc = "Runs a local callback.",
    Callback = function() print("Button callback ran") end,
})
inputGroup:Toggle({
    Title = "Enable sample",
    Flag = "showcase-enabled",
    Default = true,
    Callback = function(value) print("Toggle:", value) end,
})
inputGroup:Checkbox({
    Title = "Checkbox sample",
    Flag = "showcase-checkbox",
    Default = false,
    Callback = function(value) print("Checkbox:", value) end,
})
inputGroup:Slider({
    Title = "Amount",
    Flag = "showcase-amount",
    Value = { Min = 0, Max = 100, Default = 35 },
    Step = 5,
    Callback = function(value) print("Slider:", value) end,
})
inputGroup:Dropdown({
    Title = "Quality",
    Flag = "showcase-quality",
    Values = { "Low", "Medium", "High" },
    Default = "Medium",
    Callback = function(value) print("Dropdown:", value) end,
})
inputGroup:Dropdown({
    Title = "Multiple values",
    Flag = "showcase-multi",
    Values = { "Alpha", "Beta", "Gamma" },
    Multi = true,
    Default = { "Alpha" },
    Callback = function(values) print("Multi-select count:", #values) end,
})
inputGroup:Input({
    Title = "Text input",
    Flag = "showcase-input",
    PlaceholderText = "Type here",
    Default = "",
    Callback = function(value) print("Input:", value) end,
})
inputGroup:Keybind({
    Title = "Test key",
    Flag = "showcase-key",
    Default = Enum.KeyCode.F6,
    Callback = function(value) print("Keybind:", value) end,
})
inputGroup:Colorpicker({
    Title = "Accent color",
    Flag = "showcase-color",
    Default = Color3.fromRGB(167, 139, 250),
    Callback = function(value) print("Color:", value) end,
})

local displayGroup = controls:Group({ Title = "Display elements", Desc = "Progress, image, code, and viewport" })
local progress = displayGroup:ProgressBar({
    Title = "Download progress",
    Flag = "showcase-progress",
    Min = 0,
    Max = 100,
    Value = 62,
    DisplayMode = "Fraction",
})
displayGroup:Button({ Title = "Advance progress", Callback = function() progress:SetValue(math.min(100, progress:GetValue() + 10)) end })
displayGroup:Image({
    Title = "Library mark",
    Image = "rbxassetid://104650551286971",
    Height = 112,
    Transparency = 0,
})
displayGroup:Code({
    Title = "Read-only code",
    Language = "lua",
    Code = 'local window = UI:CreateWindow({ Title = "Showcase" })',
    Height = 92,
    CanCopied = true,
})
local showcasePart = Instance.new("Part")
showcasePart.Name = "ShowcaseViewportPart"
showcasePart.Anchored = true
showcasePart.Size = Vector3.new(3, 2, 1)
showcasePart.Color = Color3.fromRGB(167, 139, 250)
displayGroup:Viewport({ Title = "Interactive viewport", Object = showcasePart, Height = 180, Interactive = true })
showcasePart:Destroy()
displayGroup:Divider({})
displayGroup:Space({ Size = 6 })

local row = layout:HStack({ Name = "Button row", Gap = 12 })
row:Button({ Title = "Left column", Callback = function() print("Left column") end })
row:Button({ Title = "Right column", Callback = function() print("Right column") end })
local groupRow = layout:Group({ Title = "Nested group / horizontal stack", Gap = 10 })
groupRow:Paragraph({ Title = "Horizontal group", Desc = "Each added control occupies the next column." })
groupRow:Button({ Title = "Next column", Callback = function() print("Group column") end })
local vertical = layout:VStack({ Name = "Vertical stack", Gap = 6 })
vertical:Button({ Title = "VStack item one", Callback = function() end })
vertical:Button({ Title = "VStack item two", Callback = function() end })

local themeGroup = visual:Group({ Title = "Theme manager", Desc = "Custom palette and theme tags" })
Window:AddTheme("Violet test", {
    Accent = "#A78BFA",
    Background = "#17171B",
    Outline = "#3A3744",
    Text = "#F2EFF8",
    Placeholder = "#A7A4AE",
}, "Graphite")
themeGroup:Dropdown({
    Title = "Built-in theme",
    Values = Window:GetThemes(),
    Default = Window:GetTheme(),
    Callback = function(name) Window:SetTheme(name) end,
})
themeGroup:Button({ Title = "Use custom theme", Callback = function() Window:SetTheme("Violet test") end })
themeGroup:Button({ Title = "Restore Graphite", Callback = function() Window:SetTheme("Graphite") end })
local themeConnection = Window:OnThemeChange(function(current, previous)
    print("Theme:", previous, "->", current)
end)
themeGroup:Button({ Title = "Disconnect theme listener", Callback = function() themeConnection:Disconnect() end })

local shapeGroup = visual:Group({ Title = "Shape helper", Desc = "Adjustable sprite-sheet shapes" })
shapeGroup:Paragraph({
    Title = "Shape helper",
    Desc = "Use Window.Shapes:New(parent, radius, type, properties). These Roblox-hosted assets should be checked for availability and permissions.",
})
local shapeSlot = Instance.new("Frame")
shapeSlot.Name = "ShowcaseShapeSlot"
shapeSlot.BackgroundTransparency = 1
shapeSlot.Size = UDim2.new(1, 0, 0, 76)
shapeSlot.LayoutOrder = 999
shapeSlot.Parent = shapeGroup:GetContainer()
local shapeImage, shapeHandle = Window.Shapes:New(shapeSlot, 12, "Squircle", {
    Name = "ShowcaseShape",
    Size = UDim2.fromOffset(164, 54),
    Position = UDim2.fromOffset(8, 8),
    ImageColor3 = Color3.fromRGB(167, 139, 250),
})
shapeGroup:Button({ Title = "Increase corner radius", Callback = function() shapeHandle:SetRadius(18) end })

local iconGroup = keyTab:Group({ Title = "Local icon manager", Desc = "Local SVG and registered icons" })
iconGroup:Paragraph({
    Title = "Icon sources",
    Desc = "Bundled names, namespaced packs, registered icons, inline SVG, and Roblox asset IDs are resolved by LuaInterface's IconManager.",
})
iconGroup:Button({ Title = "Test icon lookup", Callback = function()
    local icon = Window:GetIcon("lucide:keyboard")
    print("Icon lookup:", icon ~= nil)
end })
iconGroup:Keybind({ Title = "Key page test", Flag = "showcase-key-page", Default = Enum.KeyCode.F7, Callback = function() print("F7") end })

local notificationGroup = noticeTab:Group({ Title = "Notification system", Desc = "Queue, icon, actions, and placement" })
notificationGroup:Button({ Title = "Show icon notification", Callback = function()
    Window:Notify({
        Title = "Showcase notification",
        Message = "Icon, content, action, and positioning are being tested.",
        Type = "Success",
        Duration = 6,
        Icon = "lucide:save",
        Actions = {{ Title = "Acknowledge", Callback = function() print("Acknowledged") end }},
    })
end })
notificationGroup:Button({ Title = "Move notifications to bottom", Callback = function() Window:SetNotificationPosition("BottomRight") end })
notificationGroup:Button({ Title = "Show simple info", Callback = function() Window:Notify("Direct-message notification test.") end })

local acrylicGroup = acrylicTab:Group({ Title = "Acrylic / blur", Desc = "Opt-in projected glass and depth-of-field effect" })
acrylicGroup:Paragraph({
    Title = "Performance note",
    Desc = "The blur is global to the 3D scene while active and may vary with graphics settings. Disable it if the client slows down.",
})
acrylicGroup:Toggle({ Title = "Enable Acrylic", Flag = "showcase-acrylic", Default = false, Callback = function(value)
    Window:SetAcrylic(value)
    print("Acrylic:", value)
end })
acrylicGroup:Slider({ Title = "Glass distance", Min = 0.6, Max = 3, Default = 0.75, Step = 0.05, Callback = function(value)
    Window.Acrylic:SetDistance(value)
end })
acrylicGroup:Button({ Title = "Show Acrylic state", Callback = function()
    local state = Window:GetAcrylicState()
    print("Acrylic state:", state.Enabled, state.Visible, state.Distance)
end })

local SaveManager = LuaInterface.SaveManager
SaveManager:SetFolder("LuaInterfaceShowcase")
local saveGroup = configTab:Group({ Title = "Configuration", Desc = "Theme and control values" })
saveGroup:Paragraph({
    Title = "Local storage",
    Desc = "Save and load require filesystem functions supplied by the client environment.",
})
saveGroup:Button({ Title = "Save current values", Callback = function()
    local ok, err = SaveManager:Save("showcase")
    Window:Notify({
        Title = ok and "Configuration saved" or "Save unavailable",
        Message = ok and "Theme and control values were stored." or tostring(err),
        Type = ok and "Success" or "Warning",
        Duration = 4,
    })
end })
saveGroup:Button({ Title = "Load saved values", Callback = function()
    local ok, err = SaveManager:Load("showcase")
    Window:Notify({
        Title = ok and "Configuration loaded" or "Load unavailable",
        Message = ok and "Theme and control values were restored." or tostring(err),
        Type = ok and "Success" or "Warning",
        Duration = 4,
    })
end })

Window:Notify({ Title = "Showcase ready", Content = "Example tabs and controls are ready.", Type = "Info", Duration = 5, Icon = "lucide:boxes" })
