# WindUI-shaped compatibility layer

**Release:** LuaInterface `1.1.0-beta`

**Reference:** the user-provided WindUI `v1.6.65` bundle; this adapter is not an official WindUI release.
**Publication status:** published on the LuaInterface `main` branch.

This is an adapter over LuaInterface's own Roblox GUI objects and lifecycle. It does **not** embed WindUI, run its loader, fetch its icon registry, or make HTTP requests for icons. The original LuaInterface methods remain available.

## Run the example

Run `LuaInterface.lua` in a trusted Roblox client context, then run [`examples/WindUICompat.lua`](../examples/WindUICompat.lua). The example uses the public compatibility API and can be adapted to load the published source URL in your trusted client.

## Window and navigation

`CreateWindow` returns the LuaInterface API table, so both WindUI-style calls and the existing API are available on that value.

```lua
local Window = LuaInterface:CreateWindow({
    Title = "Control panel",
    Author = "Local test",
    Icon = "lucide:home",
    Theme = "Graphite",
    Acrylic = false,
    AutoShow = true,
    KeepDefaultTabs = true,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(900, 600),
})

local Section = Window:Section({ Title = "GENERAL" })
local Tab = Section:Tab({
    Title = "Overview",
    Desc = "Window and tab example",
    Icon = "home", -- names resolve through the local Lucide subset
})
local Group = Tab:Group({ Title = "Controls", Desc = "Example group" })
Group:Button({ Title = "Run", Callback = function() print("Run") end })
```

Supported window aliases include `Author` → `Footer`, `ToggleKey` → `ToggleKeybind`, `Folder` for the SaveManager, theme selection, and opt-in `Acrylic`. Tabs accept `Title`/`Name`, `Desc`/`Description`, `Icon`, `IconPack`, `IconSize`, `IconColor`, `Order`, `Visible`, `Select`, and `Locked`. The visible default palette is `Graphite`; the old theme key `Obsidian` still resolves to it for saved-config and script compatibility. The built-in `Home` and `Theme` tabs are still governed by `KeepDefaultTabs`.

`Section:Tab(...)` places a heading in the sidebar and applies an order to its tabs. `Tab:Group(...)`/`Tab:Section(...)` create a groupbox inside the page. `Window:Tab(...)` is also available.

## Elements

The adapter covers every element module identified in the supplied bundle:

| Element | Local behavior / compatible options |
|---|---|
| `Button` | `Title`/`Text`, `Desc`, `Callback`/`Func`, `Disabled`, `Risky`, `Cooldown` |
| `Toggle`, `Checkbox` | `Title`, `Default`/`Value`, `Callback`, `Flag`/`Id` |
| `Slider` | `Value={Min, Max, Default}` or `Min`/`Max`/`Default`, `Step`, `Decimals`, `Callback` |
| `Dropdown` | `Values`/`Options`, `Default`, `Multi`, `AllowNone`, `Searchable`; Multi callbacks receive a selected-values array |
| `Input` | `Default`/`Value`, `PlaceholderText`, `Callback` |
| `Keybind` | `Default`/`Key`, `Mode`, `Callback` |
| `Colorpicker` | `Default`/`Value`, `Callback` |
| `Paragraph` | `Title`, `Desc`/`Content` |
| `ProgressBar` | `Value`, `Min`, `Max`, `DisplayMode`, `Format`; update with `SetValue`/`SetProgress` |
| `Image` | Roblox image id, `Color`, `Transparency`, `CornerRadius` |
| `Code` | read-only code text with optional copy button and `OnCopy` |
| `Divider`, `Space` | separators and fixed layout spacing |
| `Group`, `HStack`, `VStack` | nested horizontal/vertical GUI containers; HStack uses one vertical column per added control |
| `Viewport` | local `ViewportFrame`, optional cloned `Object`, `Camera`, and interactive orbit |
| `Section` | sidebar heading via `Window:Section`, or groupbox alias via `Tab:Section` |

Each control is still a LuaInterface element and retains its local `Get`, `SetValue`, `SetVisible`, and change-event methods where implemented. Multi-select callbacks are normalized to a list; the local control state remains keyed internally for saving.

## Themes

Built-in themes are the LuaInterface themes returned by `GetThemes()`. `Theme` accepts a built-in name, or a table with a `Name` and color fields; custom themes can also be added after creation:

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

Common theme fields such as `Accent`, `Primary`, `Background`, `Window`, `Dialog`, `Surface`, `Secondary`, `Tertiary`, `Outline`, `Border`, `Placeholder`, `Icon`, `Danger`, and `Error` map to LuaInterface's palette. Hex strings are accepted. `SetThemeTag(instance, {BackgroundColor3 = "Accent"})` applies a token immediately and reapplies it on theme changes.

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

Shape names and sprite-sheet asset IDs come from the supplied reference. The image assets remain Roblox-hosted assets; the bundle's MIT notice does not establish a separate license for those assets. Availability and use permissions should be checked in the target experience.

## Icons

Tabs, the window logo, notifications, groupbox headers, and controls use LuaInterface's local `IconManager`. Names such as `home` resolve through the bundled Lucide subset; `lucide:home`, other registered packs, Roblox asset IDs, inline SVG, and registered custom icons are also supported where the control accepts an icon. The upstream remote icon bootstrap is intentionally not used. The included name registry is a subset, not a promise that every WindUI/Lucide symbol exists.

## Notifications

Both direct and manager calls accept the common `Title`/`Heading`, `Content`/`Message`/`Description`, `Type`, `Duration`, `Icon`, and `Actions` fields:

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

`Notify`, `NotificationManager:Notify`, and `NotifyWindow` accept both dot and colon invocation in this adapter.

## Acrylic / blur

Acrylic is off by default. Enable it with `Acrylic = true` in `CreateWindow`, or call `Window:SetAcrylic(true)`. `Window:SetAcrylic(false)` removes the projected glass surface and restores any `DepthOfFieldEffect.Enabled` values captured by the library. The implementation projects a Glass material mesh over the window and uses Roblox depth-of-field; it is a visual approximation, not a platform-native per-window blur. The blur affects the 3D scene globally while active, so it must be tested in the target client, especially on mobile. It is not runtime-validated by this local static review.

## Known boundaries

- This adapter targets the elements and common fields found in the provided bundle, not every internal WindUI service, animation, localization key, input hook, key system, or undocumented argument overload.
- UI controls are rebuilt from LuaInterface components, so exact pixel parity and every callback timing detail are not promised.
- HStack uses measured columns and a configurable `Gap`; it is not a full flexbox engine.
- Acrylic relies on client camera/Lighting behavior and may vary by graphics quality.
- Run this preview locally first. No commit, tag, release, or push has been made.
