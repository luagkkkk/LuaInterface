-- Run only in a compatible client environment that allows remote loading.
local LuaInterface = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))()

local Window = LuaInterface:CreateWindow({
    Title = "LuaInterface Example",
    Footer = "Basic example",
})

local Tab = Window:AddTab("Dashboard", {
    Icon = "home",
    Description = "A minimal example",
})

local Group = Tab:AddLeftGroupbox({
    Name = "Controls",
    IconName = "settings",
})

Group:AddButton({
    Text = "Print a message",
    Func = function()
        print("LuaInterface is ready")
    end,
})

Group:AddToggle("demo-enabled", {
    Name = "Enabled",
    Default = false,
    Callback = function(enabled)
        print("Enabled:", enabled)
    end,
})
