# Compatibility adapter

**Release:** LuaInterface `1.1.2-beta`, published on `main`. For source attribution, see [Third-party notices](THIRD_PARTY_NOTICES.md).

The adapter maps window, navigation, group, element, theme, icon, and notification options onto LuaInterface's existing Roblox UI system. Existing methods such as `CreateWindow`, `AddTab`, and the groupbox API remain available. No remote UI loader or icon registry is required.

`SetScale` scales the window while keeping its top-left screen position stable. `SetSize` and the resize grip use the same logical-size convention when UIScale is active. Fullscreen animates size and position; the transition is skipped when reduced motion or the window-toggle animation is disabled.

## Run the Showcase

Load `LuaInterface.lua` in a trusted Roblox client context, then execute [`examples/Showcase.lua`](../examples/Showcase.lua). The library by itself opens **Home** and **Theme**; the Showcase creates its own pages and sets `KeepDefaultTabs = false` so those pages replace the built-ins.

## Window and navigation

```lua
local Window = LuaInterface:CreateWindow({
    Title = "Control panel",
    Author = "Local test",
    Icon = "lucide:home",
    Theme = "Graphite",
    Acrylic = false,
    AutoShow = true,
    KeepDefaultTabs = false,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(900, 600),
})

local Section = Window:Section({ Title = "CONTROLS" })
local Tab = Section:Tab({
    Title = "Dashboard",
    Desc = "Window and tab example",
    Icon = "home",
})
local Group = Tab:Group({ Title = "Controls", Desc = "Example group" })
Group:Button({ Title = "Run", Callback = function() print("Run") end })
```

Window aliases include `Author` → `Footer`, `ToggleKey` → `ToggleKeybind`, `Folder` for SaveManager, theme selection, and opt-in `Acrylic`. Tabs accept `Title`/`Name`, `Desc`/`Description`, `Icon`, `IconPack`, `IconSize`, `IconColor`, `Order`, `Visible`, `Select`, and `Locked`. `KeepDefaultTabs` controls whether Home and Theme remain after the first custom tab is created.

`Section:Tab(...)` adds a heading in the sidebar and orders its tabs. `Tab:Group(...)` and `Tab:Section(...)` create a group inside the page. `Window:Tab(...)` is also available.

## Elements

| Element | Supported options and behavior |
|---|---|
| `Button` | `Title`/`Text`, `Desc`, `Callback`/`Func`, `Disabled`, `Risky`, `Cooldown` |
| `Toggle`, `Checkbox` | `Title`, `Default`/`Value`, `Callback`, `Flag`/`Id` |
| `Slider` | `Value={Min, Max, Default}` or separate `Min`/`Max`/`Default`, `Step`, `Decimals`, `Callback` |
| `Dropdown` | `Values`/`Options`, `Default`, `Multi`, `AllowNone`, `Searchable`; multi-select callbacks receive an array |
| `Input` | `Default`/`Value`, `PlaceholderText`, `Callback` |
| `Keybind` | `Default`/`Key`, `Mode`, `Callback` |
| `Colorpicker` | `Default`/`Value`, `Callback` |
| `Paragraph` | `Title`, `Desc`/`Content` |
| `ProgressBar` | `Value`, `Min`, `Max`, `DisplayMode`, `Format`; update with `SetValue`/`SetProgress` |
| `Image` | Roblox image id, `Color`, `Transparency`, `CornerRadius` |
| `Code` | Read-only code text, optional copy button and `OnCopy` |
| `Divider`, `Space` | Separators and fixed layout spacing |
| `Group`, `HStack`, `VStack` | Nested containers; HStack lays added controls into columns |
| `Viewport` | Local `ViewportFrame`, optional cloned `Object`, `Camera`, and interactive orbit |
| `Section` | Sidebar heading via `Window:Section`, or group alias via `Tab:Section` |

Controls retain their local `Get`, `SetValue`, `SetVisible`, and change-event methods where implemented. Control values stay available to the SaveManager through their flags.

## Themes

Built-in themes are returned by `GetThemes()`. `Theme` accepts a built-in name or a table containing a `Name` and color fields. Custom themes can be registered after creating the window:

```lua
Window:AddTheme("Violet test", {
    Accent = "#A78BFA",
    Background = "#17171B",
    Outline = "#34323C",
    Text = "#F1EFF5",
}, "Graphite")
Window:SetTheme("Violet test")

local themeConnection = Window:OnThemeChange(function(current, previous)
    print(previous, "->", current)
end)
```

Color fields such as `Accent`, `Primary`, `Background`, `Window`, `Dialog`, `Surface`, `Secondary`, `Tertiary`, `Outline`, `Border`, `Placeholder`, `Icon`, `Danger`, and `Error` map to the library palette. Hex strings are accepted. `SetThemeTag(instance, {BackgroundColor3 = "Accent"})` applies a token now and reapplies it after theme changes.

## Shapes

```lua
local shapeHost = Instance.new("Frame")
shapeHost.BackgroundTransparency = 1
shapeHost.Size = UDim2.fromOffset(180, 72)
shapeHost.Parent = Window:GetGui()

local shapeImage, shape = Window.Shapes:New(
    shapeHost, 12, "Squircle",
    { Size = UDim2.fromOffset(160, 56), Position = UDim2.fromOffset(8, 8), ImageColor3 = Color3.fromRGB(167, 139, 250) }
)
-- shape:SetRadius(16); shape:SetType("SquircleOutline"); shape:Destroy()
```

The shape helper uses Roblox-hosted sprite-sheet images. Their availability and permissions are separate from the library's code license; check them in the target experience.

## Icons

Tabs, the window logo, notifications, group headers, and controls use the local `IconManager`. The bundled name set includes common Lucide-style outlines; namespaced packs, Roblox asset IDs, inline SVG, and registered custom icons are supported where a control accepts an icon. SVG paths are drawn as Roblox GUI objects, not loaded as remote images.

## Notifications

`Notify`, `NotificationManager:Notify`, and `NotifyWindow` accept `Title`/`Heading`, `Content`/`Message`/`Description`, `Type`, `Duration`, `Icon`, and `Actions`. A bell is used when no icon is supplied. Custom icons and colors remain available.

```lua
Window:Notify({
    Title = "Saved",
    Message = "The local config is ready.",
    Type = "Success",
    Duration = 4,
    Icon = "lucide:save",
    Actions = {{ Title = "Undo", Callback = function() print("Undo") end }},
})
Window:SetNotificationPosition("BottomRight") -- or TopLeft/TopCenter/etc.
```

Both dot and colon invocation are supported by the notification adapter.

## Acrylic / blur

Acrylic is off by default. Set `Acrylic = true` in `CreateWindow` or call `Window:SetAcrylic(true)`. `Window:SetAcrylic(false)` removes the projected glass surface and restores `DepthOfFieldEffect.Enabled` values captured by the library. This is an approximation using a projected Glass surface and Roblox depth-of-field, not a platform-native per-window blur. It affects the 3D scene globally while active and should be checked on the target device, especially mobile.

## Runtime requirements and limits

- Load from a Roblox client context with `Players.LocalPlayer` and that player's `PlayerGui` available. The library raises an error outside that context.
- Static syntax review does not replace runtime testing in Roblox Studio or a client.
- The SVG parser supports common outline paths and primitives; it is not a complete SVG/CSS renderer.
- HStack uses fixed measured columns and `Gap`; it is not a flexbox engine.
- Acrylic appearance and performance depend on camera, Lighting, and graphics quality.
