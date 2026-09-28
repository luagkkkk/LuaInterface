# LuaInterface

![Version](https://img.shields.io/badge/version-5.4.3-blue)
![Platform](https://img.shields.io/badge/platform-Roblox-red)
![Language](https://img.shields.io/badge/language-Luau-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A responsive Roblox Luau interface library with theming, reusable components, notifications, configuration helpers, and a built-in vector icon manager.

## Features

- Responsive desktop, tablet, and mobile layouts
- Built-in themes and runtime theme switching
- Tabs, groupboxes, and nested tabboxes
- Buttons, toggles, sliders, dropdowns, inputs, keybinds, and color pickers
- Notifications, dialogs, loading overlays, and search
- Dependency helpers for conditional UI
- Configuration save/load/export helpers when filesystem functions are available
- Icon registry, aliases, namespaced lookup, tinting, and sizing
- Built-in vector icons and inline SVG outline rendering
- Cleanup, lifecycle, and error-handling helpers

> **Icon-pack naming:** `lucide:settings`, `tabler:settings`, and `phosphor:settings` are namespace aliases to LuaInterface's own registered icon renderers. They do **not** mean the official Lucide, Tabler, or Phosphor SVG collections are bundled.

## Installation

For environments that allow `loadstring` and HTTP requests:

```lua
local LuaInterface = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))()
```

In Roblox Studio or a project that does not allow remote `loadstring`, place the source in a trusted `ModuleScript` and require it from a compatible client context. The library uses `Players.LocalPlayer` and `PlayerGui`.

Only execute code you trust. `loadstring` availability and filesystem helper functions vary by environment. Configuration file operations are optional and require compatible filesystem functions such as `readfile` and `writefile`.

## Quick start

```lua
local LuaInterface = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))()

local Window = LuaInterface:CreateWindow({
    Title = "My Interface",
    Footer = "LuaInterface 5.4.3",
})

local Tab = Window:AddTab("Dashboard", {
    Icon = "home",
    Description = "A small example",
})

local Group = Tab:AddLeftGroupbox({
    Name = "Controls",
    IconName = "settings",
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
```

The script currently includes demonstration tabs and components in its startup UI. Use `CreateWindow`, `AddTab`, and the component methods to configure and extend it.

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
- Raw SVG is not assigned to a Roblox `ImageLabel`. Common outline SVG paths/primitives are parsed and drawn using Roblox GUI objects. It is not a complete SVG/CSS renderer; see [ICONS.md](docs/ICONS.md) for supported syntax and limitations.
- The project has been statically syntax-checked. Runtime behavior still needs to be tested in Roblox Studio or the target client environment.

## License

MIT. See [LICENSE](LICENSE).
