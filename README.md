# LuaInterface

**Current build:** `1.1.0-beta` · Roblox client UI library, written in Luau.
**Compatibility:** WindUI v1.6.65-style API patterns mapped to LuaInterface components; see the credited adapter guide.

LuaInterface's own window system, Graphite theme, tabs, groupboxes, controls, SVG icon manager, notification queue, and SaveManager remain the implementation. The adapter maps common window, tab, element, theme, shape, notification, and icon APIs onto those components. It does not bundle the reference library or run its remote loader. The compatibility guide credits the v1.6.65 reference bundle.

## Use the published build

The following URL loads the published `main` build (`1.1.0-beta`):

```lua
local source, err = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, err)
local LuaInterface = source()
assert(type(LuaInterface) == "table", "LuaInterface did not initialize")

local Window = LuaInterface:CreateWindow({
    Title = "My panel",
    Footer = "LuaInterface",
    AutoShow = true,
})
local Tab = Window:AddTab("Dashboard", { Icon = "lucide:home" })
local Group = Tab:AddLeftGroupbox({ Name = "Controls" })
Group:AddToggle("enabled", { Name = "Enabled", Default = false })
```

The library needs `Players.LocalPlayer` and that player's `PlayerGui`. In Studio, put the source in a trusted `ModuleScript` and require it from a `LocalScript` if `loadstring` is unavailable. Filesystem functions are optional and only needed for SaveManager file operations.

## Try the compatibility example

1. Run `LuaInterface.lua` in a trusted Roblox client context.
2. Run [`examples/WindUICompat.lua`](examples/WindUICompat.lua).
3. Check navigation, spacing, components, icons, notifications, and Acrylic on the target device.

See [WindUI compatibility](docs/WINDUI-COMPATIBILITY.md) for the API mapping, reference credit, and boundaries.

## Existing library guides

- [Window, tabs, and controls](docs/API.md)
- [Icons](docs/ICONS.md)
- [Themes](docs/THEMES.md)
- [SaveManager](docs/CONFIG.md)
- [Lua examples](examples/)

## Status and license

The `1.1.0-beta` build is published on `main`. Syntax and static structure were checked locally; visual behavior, input, Acrylic blur, and Roblox asset availability still require testing in the target client/Studio.

MIT. See [LICENSE](LICENSE). The sprite-sheet images used by the shape helper are separate Roblox-hosted assets; the source bundle's MIT notice does not establish a license for those assets.
