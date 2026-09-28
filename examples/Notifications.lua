local LuaInterface = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))()

LuaInterface:Notify({
    Type = "Success",
    Title = "Ready",
    Content = "The interface has loaded.",
    Duration = 4,
})

LuaInterface:Notify({
    Type = "Warning",
    Title = "Example",
    Content = "Notifications can include a title and body.",
    Duration = 5,
})

local persistent = LuaInterface:Notify({
    Type = "Info",
    Title = "Persistent notification",
    Content = "This one stays until it is dismissed.",
    Duration = 0,
})

-- Call persistent:Destroy() when the notification should be dismissed.
