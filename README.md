# LuaInterface

![Version](https://img.shields.io/badge/version-5.4.7-blue)
![Platform](https://img.shields.io/badge/platform-Roblox-red)
![Language](https://img.shields.io/badge/language-Luau-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A responsive Roblox Luau interface library with reusable components, a clean tab-first startup, theme support, inline SVG icons, notifications, and configuration helpers.

## Features

- Responsive desktop, tablet, and mobile layouts
- Obsidian-inspired default theme, plus runtime theme switching
- User-created tabs, groupboxes, and nested tabboxes
- Buttons, toggles, sliders, dropdowns, inputs, keybinds, and color pickers
- Notifications, dialogs, loading overlays, and search
- Dependency helpers for conditional UI
- Configuration save/load/export helpers when compatible filesystem functions are available
- Icon registry, aliases, `lucide:`-style namespaced lookup, tinting, sizing, image assets, and inline SVG rendering
- Cleanup, lifecycle, and error-handling helpers

## Installation

Load the library from a compatible **client** environment that permits `loadstring` and HTTP requests:

```lua
local source, loadError = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, loadError)

local LuaInterface = source()
assert(type(LuaInterface) == "table", "LuaInterface did not initialize")
```

The library needs `Players.LocalPlayer` and that player's `PlayerGui`. It waits briefly for them and raises a descriptive error if it is running on the server or the client UI is unavailable, rather than silently returning `nil`.

In Roblox Studio or a project that does not allow remote `loadstring`, place the source in a trusted `ModuleScript` and require it from a compatible client context. Only execute code you trust. Filesystem functions such as `readfile` and `writefile` are optional and vary by environment.

## Quick start

```lua
local Window = LuaInterface:CreateWindow({
    Title = "My Interface",
    Footer = "LuaInterface 5.4.7",
})

Window:SetTheme("Obsidian") -- this is also the default theme

local Tab = Window:AddTab("Dashboard", {
    Icon = "lucide:settings",
    Description = "Overview",
})

local Group = Tab:AddLeftGroupbox({
    Name = "Controls",
    IconName = "sliders",
})

Group:AddButton({
    Text = "Say hello",
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

Window:AddKeybind("toggle-menu", {
    Name = "Show/Hide menu",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        Window:Toggle()
    end,
})
```

**No component demo tabs are created at startup.** When the first user tab is added, it is selected automatically and the built-in `Home`/`Theme` tabs are removed so the window shows the tabs your script created. Pass `KeepDefaultTabs = true` to `CreateWindow` to retain those two system tabs:

```lua
local Window = LuaInterface:CreateWindow({
    Title = "My Interface",
    KeepDefaultTabs = true,
})
```

## Icons

The tab option accepts a built-in name (`"settings"`), a supported namespace form (`"lucide:settings"`), an asset ID/URI, inline SVG markup, or a renderer function. For example:

```lua
local Tab = Window:AddTab("Settings", {Icon = "lucide:settings", IconSize = 18})
```

The built-in `lucide:`, `tabler:`, and `phosphor:` namespaces expose LuaInterface's **included subset** of renderers; they do not bundle the full official icon collections. See [ICONS.md](docs/ICONS.md) for the exact supported names and custom SVG examples.

## Documentation

- [API reference](docs/API.md)
- [Icons and inline SVG](docs/ICONS.md)
- [Themes](docs/THEMES.md)
- [Configuration](docs/CONFIG.md)

## Examples

- [Basic interface](examples/Basic.lua)
- [IconManager and inline SVG](examples/Icons.lua)
- [Notifications](examples/Notifications.lua)
- [Combined example](examples/Full.lua)

## Compatibility notes

- This is a Roblox Luau UI library, not a standalone Lua UI toolkit.
- Raw SVG is not assigned to a Roblox `ImageLabel`. Supported outline paths and primitives are parsed and drawn using Roblox GUI objects. This is a lightweight icon renderer, not a complete SVG/CSS engine.
- The source passes static syntax checks. Roblox Studio/client runtime behavior should still be verified in the target experience.

## License

MIT. See [LICENSE](LICENSE).
