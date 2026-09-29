# LuaInterface

**Current version: `1.0.0-beta`** · A Roblox UI library written in Luau.

LuaInterface provides a tabbed interface for Roblox client scripts: a responsive window, groupboxes, controls, themes, notifications, and vector icons rendered with Roblox GUI objects. The default theme is **Obsidian**, with graphite surfaces and a violet accent.

## Load the library

Run in a client environment that permits HTTP requests and `loadstring`:

```lua
local source, err = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, err)

local LuaInterface = source()
assert(type(LuaInterface) == "table", "LuaInterface did not initialize")
```

The library needs `Players.LocalPlayer` and that player's `PlayerGui`. In a Roblox Studio project that does not allow `loadstring`, place the source in a trusted `ModuleScript` and require it from a `LocalScript`. Filesystem functions such as `readfile` and `writefile` are environment-dependent and are not needed to open the UI.

## Quick start

```lua
local Window = LuaInterface:CreateWindow({
    Title = "My panel",
    Footer = "LuaInterface 1.0.0-beta",
    AutoShow = true,
})

local Reach = Window:AddTab("Reach", {
    Icon = "lucide:target",
    Description = "Reach controls",
})

local Controls = Reach:AddLeftGroupbox({Name = "Settings"})

Controls:AddToggle("reach-enabled", {
    Name = "Enabled",
    Default = false,
    Callback = function(enabled)
        print("Reach:", enabled)
    end,
})

Controls:AddSlider("reach-size", {
    Name = "Size",
    Min = 1,
    Max = 20,
    Default = 4,
    Rounding = 1,
    Callback = function(value)
        print("Size:", value)
    end,
})
```

The first custom tab is selected automatically. The built-in `Home` and `Theme` pages are removed when custom tabs are added; pass `KeepDefaultTabs = true` to `CreateWindow` to keep them.

## Menu key

`RightShift` is the default global show/hide key. Do not bind a second action to `RightShift` that also calls `Window:Toggle()`, or one keypress can toggle the window twice. Use another key for a component keybind, or set `ToggleKeybind` when creating the window.

## Icons and themes

Tabs accept built-in names such as `lucide:target`, Roblox image IDs, simple inline SVG strings, or renderer functions. The `lucide:`, `tabler:`, and `phosphor:` prefixes map to the subset included in this repository; they are not the full upstream collections. See [Icons](docs/ICONS.md) and [Themes](docs/THEMES.md).

## Guides and examples

- [Window, tabs, and controls](docs/API.md)
- [Icons](docs/ICONS.md)
- [Themes](docs/THEMES.md)
- [Saving and loading configurations](docs/CONFIG.md)
- [Lua examples](examples/): [basic UI](examples/Basic.lua), [combined controls](examples/Full.lua), [icons](examples/Icons.lua), and [notifications](examples/Notifications.lua)

## Project status

This is a beta release. Lua files are checked for syntax before updates; visual and interaction testing should be done in Roblox Studio or the target client. When reporting an issue, include the version and the full console message.

## License

MIT. See [LICENSE](LICENSE).
