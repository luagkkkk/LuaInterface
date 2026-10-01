# API Reference

This page covers the calls most scripts use with LuaInterface `1.1.2-beta`. For less common options, see [`LuaInterface.lua`](../LuaInterface.lua).

## Window

The library chunk returns its API table:

```lua
local source = loadstring(game:HttpGet(URL))
local LuaInterface = source()

local Window = LuaInterface:CreateWindow({
    Title = "My panel",
    Footer = "1.1.2-beta",
    AutoShow = true,
    Resizable = true,
})
```

`CreateWindow(config)` configures the window and returns the window API. Graphite is the default theme. The config can include `Center`, `Position`, `ToggleKeybind`, `AutoShow`, and `KeepDefaultTabs`. By default, the first custom tab is selected and the built-in pages are removed.

Mobile header controls remain enabled by default. Set `ShowMobileButtons = false` in the window config or call `Window:SetMobileButtons(false)` to hide minimize, maximize, and close on phone-sized viewports; tablet and desktop controls remain visible.

Common window methods:

```lua
Window:Open()
Window:Close()
Window:Toggle()
Window:Minimize()
Window:SetPosition(UDim2.fromScale(0.5, 0.5))
Window:SetScale(0.9)
Window:SetTheme("Graphite")
```

`SetSize(width, height)` sets the window's base dimensions; `SetScale` applies UIScale and keeps the top-left screen position in place as the window grows or shrinks. The resize grip converts scaled display dimensions back to base dimensions, so repeatedly resizing does not compound the scale. `Fullscreen()` animates the size and position with TweenService and restores the prior position and size when toggled off. Reduced-motion mode, or `Animations.ToggleWindow = false`, disables that transition.

`RightShift` is the default global menu key. Do not reuse it for a component callback that also calls `Window:Toggle()`.

## Tabs and groupboxes

```lua
local Controls = Window:AddTab("Controls", {
    Icon = "lucide:target",
    Description = "Dashboard controls",
})
local Left = Controls:AddLeftGroupbox({Name = "Settings"})
local Right = Controls:AddRightGroupbox({Name = "Actions"})
```

A tab icon can be a built-in name, a `pack:name` identifier, an image ID, inline SVG, or a renderer function. `IconSize` changes its size. See [Icons](ICONS.md) for available names.

## Controls

### Button and toggle

```lua
Left:AddButton({
    Text = "Restore",
    Func = function()
        print("Action ran")
    end,
})

local enabled = Left:AddToggle("feature-enabled", {
    Name = "Enable feature",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})
```

### Slider and color picker

```lua
Left:AddSlider("platform-size", {
    Name = "Platform size",
    Min = 2,
    Max = 30,
    Default = 8,
    Rounding = 1,
    Callback = function(value)
        print(value)
    end,
})

Left:AddColorPicker("platform-color", {
    Title = "Platform color",
    Default = Color3.fromRGB(90, 160, 255),
    Callback = function(color, transparency)
        print(color, transparency)
    end,
})
```

Use unique `Index` values (or unique first arguments to group methods) for controls that should be saved. Components return control objects; available methods depend on the component and may include `Get`, `SetValue`, and `Destroy`.

## Notifications

```lua
Window:Notify({
    Type = "Success", -- Info, Success, Warning, Error, Loading, Debug, Option
    Title = "Ready",
    Content = "Settings have been applied.",
    Duration = 3,
})
```

## Cleanup

`Window:Destroy()` or `Window:Unload()` removes the UI and connections managed by the library. Disconnect any connections your own script created (for example, `RunService.Heartbeat`) before destroying the window.
