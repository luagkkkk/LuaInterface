# API Reference

The public object is returned by the library script. The examples below assume it is stored in `LuaInterface`.

## Window

The UI is initialized when the source is loaded in a compatible client context. `CreateWindow(config)` applies window settings and returns the library API object.

```lua
local Window = LuaInterface:CreateWindow({
    Title = "My Interface",
    Footer = "Example",
    AutoShow = true,
    Resizable = true,
})
```

Set `KeepDefaultTabs = true` if the built-in `Home` and `Theme` tabs should remain visible after creating your own tabs. By default, the first custom tab removes those two system tabs and becomes selected; no component demo tabs are shipped in the startup UI.

```lua
local Window = LuaInterface:CreateWindow({
    Title = "My Interface",
    KeepDefaultTabs = true,
})
```

Useful window methods include:

- `CreateWindow(config)` / `ConfigureWindow(config)`
- `Open()`, `Close()`, `Toggle()`, `Minimize()`, `Fullscreen()`
- `SetSize(width, height)`, `SetPosition(position)`
- `SetTheme(name)`, `Destroy()` / `Unload()`
- `AddKeybind(id, config)`, which places the keybind control on the currently selected tab

```lua
Window:AddKeybind("toggle-menu", {
    Name = "Show/Hide menu",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        Window:Toggle()
    end,
})
```

## Tabs and groupboxes

```lua
local Tab = Window:AddTab("Dashboard", {
    Icon = "lucide:settings",
    IconSize = 18,
    Description = "Overview",
})

local Left = Tab:AddLeftGroupbox({
    Name = "Controls",
    Description = "Main actions",
    IconName = "sliders",
})

local Right = Tab:AddRightGroupbox({Name = "Status"})
```

`AddTab(name, config)` accepts a built-in icon name, a supported namespaced icon name, an asset ID/URI, inline SVG markup, or a renderer function. The first tab is selected automatically unless `Select = false`; set `Select = true` on later tabs to select them immediately. Groupboxes support `AddLeftGroupbox`, `AddRightGroupbox`, `AddGroupbox`, and nested tabboxes. Tabs and groupboxes expose component methods such as `AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddInput`, `AddKeybind`, `AddSection`, and `AddDivider`.

## Components

### Button

```lua
Left:AddButton({
    Text = "Run",
    Func = function()
        print("Clicked")
    end,
})
```

### Toggle

```lua
local Toggle = Left:AddToggle("feature-enabled", {
    Name = "Feature enabled",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})
```

### Slider and dropdown

```lua
Left:AddSlider("volume", {
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 0,
    Callback = function(value) print(value) end,
})

Left:AddDropdown("quality", {
    Name = "Quality",
    Values = {"Low", "Medium", "High"},
    Default = "Medium",
    Callback = function(value) print(value) end,
})
```

Inputs, keybinds, color pickers, labels, sections, dividers, and multi-dropdowns are also exposed from tabs/groupboxes. Each component returns an element object with methods such as `Get`, `SetValue`, `OnChanged`, or `Destroy` where supported by that component.

## Notifications

```lua
LuaInterface:Notify({
    Type = "Success", -- Info, Success, Warning, Error, Loading, Debug, Option
    Title = "Saved",
    Content = "Your settings were saved.",
    Duration = 4,
})
```

A string can also be passed as notification content. `Duration = 0` creates a persistent notification; use the returned notification object's `Destroy()` method to close it.

## Themes

```lua
print(table.concat(LuaInterface:GetThemes(), ", "))
LuaInterface:SetTheme("Obsidian")
```

See [THEMES.md](THEMES.md) for built-in names and theme behavior.

## Icons

`LuaInterface.IconManager` exposes `Register`, `RegisterSVG`, `RegisterAlias`, `RegisterPack`, `Get`, `Resolve`, `Exists`, `Create`, `Tint`, `SetSize`, `Preload`, and `ClearCache`.

See [ICONS.md](ICONS.md) for examples and SVG limitations.

## Configuration helpers

`LuaInterface.SaveManager` provides `SetFolder`, `SetSubFolder`, `Save`, `Load`, `Delete`, `List`, `Rename`, `Export`, `Import`, `StartAutoSave`, and `StopAutoSave`. Filesystem-dependent calls return an error when the runtime does not expose compatible filesystem functions. See [CONFIG.md](CONFIG.md).

## Lifecycle and diagnostics

- `Destroy()` / `Unload()` clean up the library UI and managed connections.
- `IsAlive()` checks whether the library instance is still active.
- `GetVersion()` returns the library version.
- `GetMetrics()` returns runtime performance counters.
- `GetErrors()` and `ClearErrors()` inspect/reset captured errors.

Method details may vary by component. Consult the source when using less common options.
