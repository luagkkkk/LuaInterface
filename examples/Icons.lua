local LuaInterface = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))()

local Window = LuaInterface:CreateWindow({Title = "Icon examples"})
local Tab = Window:AddTab("Icons", {Icon = "palette"})
local Group = Tab:AddLeftGroupbox({Name = "IconManager", IconName = "settings"})
local Icons = LuaInterface.IconManager

print("Built-in icon:", Icons:Exists("settings"))
print("Namespaced alias:", Icons:Exists("lucide:settings"))
print("Missing icon:", Icons:Exists("not-a-real-icon"))

Icons:RegisterAlias("my-gear", "settings")
print("Registered alias:", Icons:Exists("my-gear"))

Icons:RegisterSVG("heart-outline", [[
<svg viewBox="0 0 24 24">
  <path d="M20 8 C20 4 15 3 12 8 C9 3 4 4 4 8 C4 13 12 20 12 20 C12 20 20 13 20 8 Z"/>
</svg>
]])

-- To render a standalone icon, provide a GuiObject parent (for example, a Frame
-- inside a ScreenGui). Tab and groupbox icons can also be supplied by name.
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
