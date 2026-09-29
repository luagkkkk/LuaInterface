local source, loadError = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, loadError)
local LuaInterface = source()
assert(type(LuaInterface) == "table", "LuaInterface did not initialize")

local Window = LuaInterface:CreateWindow({
    Title = "LuaInterface",
    Footer = "Full example",
    Resizable = true,
})

Window:SetTheme("Graphite")

local Tab = Window:AddTab("Settings", {
    Icon = "lucide:settings",
    Description = "Example controls",
})

local General = Tab:AddLeftGroupbox({
    Name = "General",
    Description = "Common controls",
    IconName = "sliders",
})

General:AddToggle("notifications-enabled", {
    Name = "Notifications",
    Default = true,
    Callback = function(enabled)
        print("Notifications enabled:", enabled)
    end,
})

General:AddSlider("volume", {
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 65,
    Rounding = 0,
    Callback = function(value)
        print("Volume:", value)
    end,
})

General:AddDropdown("quality", {
    Name = "Quality",
    Values = {"Low", "Medium", "High"},
    Default = "Medium",
    Callback = function(value)
        print("Quality:", value)
    end,
})

local Actions = Tab:AddRightGroupbox({Name = "Actions", IconName = "zap"})
Actions:AddButton({
    Text = "Show notification",
    Func = function()
        Window:Notify({
            Type = "Success",
            Title = "Saved",
            Content = "The example action ran.",
            Duration = 4,
        })
    end,
})
