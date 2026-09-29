-- Run only in a compatible client environment that allows remote loading.
local source, loadError = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, loadError)
local LuaInterface = source()
assert(type(LuaInterface) == "table", "LuaInterface did not initialize")

local Window = LuaInterface:CreateWindow({
    Title = "LuaInterface Example",
    Footer = "Basic example",
})
Window:SetTheme("Graphite")

-- This first user tab is selected automatically. Built-in Home/Theme pages
-- are removed unless CreateWindow receives KeepDefaultTabs = true.
local Tab = Window:AddTab("Dashboard", {
    Icon = "lucide:home",
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
