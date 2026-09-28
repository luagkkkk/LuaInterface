local source, loadError = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, loadError)
local LuaInterface = source()
assert(type(LuaInterface) == "table", "LuaInterface did not initialize")

local Window = LuaInterface:CreateWindow({Title = "Icon examples"})
Window:SetTheme("Obsidian")
local Tab = Window:AddTab("Icons", {Icon = "lucide:settings", IconSize = 18})
local Group = Tab:AddLeftGroupbox({Name = "IconManager", IconName = "sliders"})
local Icons = LuaInterface.IconManager

print("Built-in icon:", Icons:Exists("settings"))
print("Namespaced alias:", Icons:Exists("lucide:settings"))
print("Missing icon:", Icons:Exists("not-a-real-icon"))

Icons:RegisterAlias("my-gear", "settings")
print("Registered alias:", Icons:Exists("my-gear"))

local heartSvg = [[
<svg viewBox="0 0 24 24">
  <path d="M20 8 C20 4 15 3 12 8 C9 3 4 4 4 8 C4 13 12 20 12 20 C12 20 20 13 20 8 Z"/>
</svg>
]]
Icons:RegisterSVG("heart-outline", heartSvg)

-- Raw inline SVG also works directly in a tab's Icon option.
Window:AddTab("Favorites", {Icon = heartSvg})

-- For a standalone icon, use a GuiObject parent inside a ScreenGui.
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local host = Instance.new("Frame")
host.Name = "IconPreviewHost"
host.Size = UDim2.fromOffset(48, 48)
host.BackgroundTransparency = 1
host.Parent = playerGui

local icon = Icons:Create(host, "heart-outline", {
    Size = 22,
    Color = "Accent",
})

Icons:SetSize(icon, 26)
Icons:Tint(icon, "Text")

Group:AddButton({
    Text = "Check icon registration",
    Func = function()
        print("SVG registered:", Icons:Exists("heart-outline"))
    end,
})
