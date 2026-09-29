-- Compatibility example for LuaInterface 1.1.0-beta.
-- Execute LuaInterface.lua in a trusted client context, then run this example.
-- This example targets the published LuaInterface 1.1.0-beta API.
local LuaInterface = assert(_G.LuaInterface, "Run LuaInterface.lua in the client first")

local Window = LuaInterface:CreateWindow({
    Title = "Compatibility Preview",
    Author = "LuaInterface 1.1.0-beta",
    Icon = "boxes",
    Theme = "Graphite",
    Acrylic = false, -- turn on with the Acrylic tab after checking device performance
    AutoShow = true,
    KeepDefaultTabs = true,
    Resizable = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(900, 620),
})

-- CreateWindow returns the LuaInterface API with the compatibility methods installed.
local general = Window:Section({ Title = "GENERAL" })
local controls = general:Tab({ Title = "Elements", Desc = "Control inventory", Icon = "sliders" })
local layout = general:Tab({ Title = "Layout", Desc = "Group and stack layout", Icon = "grid" })
local appearance = Window:Section({ Title = "APPEARANCE" })
local visual = appearance:Tab({ Title = "Themes & Shapes", Icon = "palette" })
local keyTab = appearance:Tab({ Title = "Icons & Keys", Icon = "keyboard" })
local noticeTab = appearance:Tab({ Title = "Notifications", Icon = "bell" })
local acrylicTab = appearance:Tab({ Title = "Acrylic", Icon = "shield" })

local inputGroup = controls:Group({
    Title = "Common controls",
    Desc = "Callbacks and local element state",
    Icon = "settings",
})
inputGroup:Paragraph({
    Title = "Compatibility preview",
    Desc = "This page exercises the compatibility APIs in the published build.",
})
inputGroup:Button({
    Title = "Run callback",
    Desc = "A LuaInterface button through the compatibility API",
    Callback = function() print("Button callback ran") end,
})
inputGroup:Toggle({
    Title = "Enable sample",
    Flag = "preview-enabled",
    Default = true,
    Callback = function(value) print("Toggle:", value) end,
})
inputGroup:Checkbox({
    Title = "Checkbox sample",
    Flag = "preview-checkbox",
    Default = false,
    Callback = function(value) print("Checkbox:", value) end,
})
inputGroup:Slider({
    Title = "Amount",
    Flag = "preview-amount",
    Value = { Min = 0, Max = 100, Default = 35 },
    Step = 5,
    Callback = function(value) print("Slider:", value) end,
})
inputGroup:Dropdown({
    Title = "Quality",
    Flag = "preview-quality",
    Values = { "Low", "Medium", "High" },
    Default = "Medium",
    Callback = function(value) print("Dropdown:", value) end,
})
inputGroup:Dropdown({
    Title = "Multiple values",
    Flag = "preview-multi",
    Values = { "Alpha", "Beta", "Gamma" },
    Multi = true,
    Default = { "Alpha" },
    Callback = function(values) print("Multi-select count:", #values) end,
})
inputGroup:Input({
    Title = "Text input",
    Flag = "preview-input",
    PlaceholderText = "Type here",
    Default = "",
    Callback = function(value) print("Input:", value) end,
})
inputGroup:Keybind({
    Title = "Preview key",
    Flag = "preview-key",
    Default = Enum.KeyCode.F6,
    Callback = function(value) print("Keybind:", value) end,
})
inputGroup:Colorpicker({
    Title = "Accent color",
    Flag = "preview-color",
    Default = Color3.fromRGB(167, 139, 250),
    Callback = function(value) print("Color:", value) end,
})

local displayGroup = controls:Group({ Title = "Display elements", Desc = "Progress, image, code, and viewport" })
local progress = displayGroup:ProgressBar({
    Title = "Download progress",
    Flag = "preview-progress",
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
    Code = 'local window = UI:CreateWindow({ Title = "Preview" })',
    Height = 92,
    CanCopied = true,
})
local previewPart = Instance.new("Part")
previewPart.Name = "ViewportPreviewPart"
previewPart.Anchored = true
previewPart.Size = Vector3.new(3, 2, 1)
previewPart.Color = Color3.fromRGB(167, 139, 250)
displayGroup:Viewport({ Title = "Interactive viewport", Object = previewPart, Height = 180, Interactive = true })
previewPart:Destroy()
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
Window:AddTheme("Violet preview", {
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
themeGroup:Button({ Title = "Use custom theme", Callback = function() Window:SetTheme("Violet preview") end })
themeGroup:Button({ Title = "Restore Graphite", Callback = function() Window:SetTheme("Graphite") end })
local themeConnection = Window:OnThemeChange(function(current, previous)
    print("Theme:", previous, "->", current)
end)
themeGroup:Button({ Title = "Disconnect theme listener", Callback = function() themeConnection:Disconnect() end })

local shapeGroup = visual:Group({ Title = "Shape helper", Desc = "Sprite-sheet shapes from the supplied reference bundle" })
shapeGroup:Paragraph({
    Title = "Shape assets",
    Desc = "Use Window.Shapes:New(parent, radius, type, properties). The asset IDs are Roblox-hosted and should be checked for availability and permissions.",
})
local shapeSlot = Instance.new("Frame")
shapeSlot.Name = "ShapePreviewSlot"
shapeSlot.BackgroundTransparency = 1
shapeSlot.Size = UDim2.new(1, 0, 0, 76)
shapeSlot.LayoutOrder = 999
shapeSlot.Parent = shapeGroup:GetContainer()
local shapeImage, shapeHandle = Window.Shapes:New(shapeSlot, 12, "Squircle", {
    Name = "ShapePreview",
    Size = UDim2.fromOffset(164, 54),
    Position = UDim2.fromOffset(8, 8),
    ImageColor3 = Color3.fromRGB(167, 139, 250),
})
shapeGroup:Button({ Title = "Increase corner radius", Callback = function() shapeHandle:SetRadius(18) end })

local iconGroup = keyTab:Group({ Title = "Local icon manager", Desc = "No remote icon registry is used" })
iconGroup:Paragraph({
    Title = "Icon sources",
    Desc = "Bundled names, namespaced packs, registered icons, inline SVG, and Roblox asset IDs are resolved by LuaInterface's IconManager.",
})
iconGroup:Button({ Title = "Test icon lookup", Callback = function()
    local icon = Window:GetIcon("lucide:keyboard")
    print("Icon lookup:", icon ~= nil)
end })
iconGroup:Keybind({ Title = "Key page test", Flag = "preview-key-page", Default = Enum.KeyCode.F7, Callback = function() print("F7") end })

local notificationGroup = noticeTab:Group({ Title = "Notification system", Desc = "Queue, icon, actions, and placement" })
notificationGroup:Button({ Title = "Show icon notification", Callback = function()
    Window:Notify({
        Title = "Preview notification",
        Message = "Icon, content, action, and positioning are being tested.",
        Type = "Success",
        Duration = 6,
        Icon = "lucide:save",
        Actions = {{ Title = "Acknowledge", Callback = function() print("Acknowledged") end }},
    })
end })
notificationGroup:Button({ Title = "Move notifications to bottom", Callback = function() Window:SetNotificationPosition("BottomRight") end })
notificationGroup:Button({ Title = "Show simple info", Callback = function() Window:Notify("This is the direct string form.") end })

local acrylicGroup = acrylicTab:Group({ Title = "Acrylic / blur", Desc = "Opt-in projected glass and depth-of-field effect" })
acrylicGroup:Paragraph({
    Title = "Performance note",
    Desc = "The blur is global to the 3D scene while active and may vary with graphics settings. Disable it if the client slows down.",
})
acrylicGroup:Toggle({ Title = "Enable Acrylic", Flag = "preview-acrylic", Default = false, Callback = function(value)
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

Window:Notify({ Title = "Local preview ready", Content = "Use this interface to check tabs, spacing, and controls.", Type = "Info", Duration = 5, Icon = "lucide:boxes" })
