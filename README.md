# LuaInterface

**Current release:** `1.1.2-beta` · Roblox client UI library, written in Luau.

LuaInterface provides its own window, tabs, groupboxes, controls, Graphite theme, icon manager, notification queue, and SaveManager. The compatibility adapter is implemented on top of those components; it does not fetch a remote UI or icon registry. See the [compatibility guide](docs/COMPATIBILITY.md) and [third-party notices](docs/THIRD_PARTY_NOTICES.md).

## Load the published build

This URL loads the version published on `main` (`1.1.2-beta`):

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

## Run the examples

Running the library alone starts with the built-in **Home** and **Theme** pages. The showcase is a separate script:

1. Run `LuaInterface.lua` in a trusted Roblox client context.
2. Run [`examples/Showcase.lua`](examples/Showcase.lua).
3. Check the component, layout, theme, icon, notification, SaveManager, and Acrylic pages on the target client.

The showcase sets `KeepDefaultTabs = false`, so its example tabs replace the built-in pages. The library does not load demonstration pages automatically.

## Guides

- [Window, tabs, and controls](docs/API.md)
- [Compatibility adapter](docs/COMPATIBILITY.md)
- [Icons](docs/ICONS.md)
- [Themes](docs/THEMES.md)
- [SaveManager](docs/CONFIG.md)
- [Lua examples](examples/)

## Status and license

The `1.1.2-beta` build is published on `main`. Static syntax checks pass; Roblox input, avatar thumbnails, Acrylic blur, and asset rendering still need testing in the target client or Studio.

MIT. See [LICENSE](LICENSE). Shape-helper images are separate Roblox-hosted assets; the library license does not establish rights to those assets. Check their availability and permissions before shipping.
