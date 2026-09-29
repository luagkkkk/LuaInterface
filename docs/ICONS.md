# Icons

Tabs and controls use LuaInterface's `IconManager`. Built-in vectors are drawn with Roblox GUI instances, so a separate image upload is not required for each icon.

## Use an icon in a tab

```lua
local Dashboard = Window:AddTab("Dashboard", {
    Icon = "lucide:target",
    IconSize = 18,
})
```

You can also pass a plain built-in name (`"target"`), an `rbxassetid://` ID/URI, an inline SVG string, or a renderer function. The `lucide:`, `tabler:`, and `phosphor:` prefixes point to the icon subset included here; they are not the complete upstream collections. Unknown names use the fallback icon.

## Included names

`home`, `bell`, `alert`, `activity`, `user`, `keyboard`, `ping`, `server`, `save`, `settings`, `info`, `trash`, `arrow-right`, `x`, `open`, `close`, `maximize`, `square-arrow-out-up-right`, `square-arrow-out-down-left`, `boxes`, `monitor`, `wrench`, `dots`, `moon`, `plus`, `minus`, `check`, `search`, `menu`, `eye`, `eye-off`, `shield`, `sword`, `swords`, `target`, `crosshair`, `zap`, `play`, `pause`, `chevron-down`, `chevron-up`, `chevron-left`, `chevron-right`, `refresh`, `download`, `upload`, `copy`, `edit`, `folder`, `lock`, `unlock`, `star`, `heart`, `palette`, `sliders`, `filter`, `list`, `grid`, `smartphone`, `gamepad`, `globe`, `clock`, `volume`, `mic`, `trophy`, `users`, `package`, `database`, `terminal`, `code`, `help`, and `sparkles`.

Aliases: `gear` → `settings`, `magnify` → `search`, `warning` → `alert`, `delete` → `trash`, and `controls` → `sliders`.

## Register a custom icon

```lua
local Icons = LuaInterface.IconManager
local heart = [[
<svg viewBox="0 0 24 24">
  <path d="M20 8 C20 4 15 3 12 8 C9 3 4 4 4 8 C4 13 12 20 12 20 C12 20 20 13 20 8 Z"/>
</svg>
]]

Icons:RegisterSVG("heart-outline", heart)
local icon = Icons:Create(parent, "heart-outline", {
    Size = 22,
    Color = "Accent",
})

Window:AddTab("Favorites", {Icon = heart})
```

Inline SVG is parsed by LuaInterface; it is not assigned directly to an `ImageLabel`. The parser supports simple path commands (`M`, `L`, `H`, `V`, `C`, `S`, `Q`, `T`, `A`, `Z`) and common primitives (`line`, `circle`, `rect`, `polyline`, `polygon`), with basic `viewBox` and `stroke-width` handling. CSS, gradients, filters, masks, and complex transforms are outside its scope.

## Manage icons

```lua
local Icons = LuaInterface.IconManager
local icon = Icons:Create(parent, "tabler:swords", {Size = 20, Color = "Text"})
Icons:Tint(icon, "Accent")
Icons:SetSize(icon, 28)
Icons:RegisterAlias("favorite", "heart-outline")
```

`Color` accepts a `Color3` or theme tokens such as `Accent`, `Text`, `SubText`, `Icon`, `Button`, and `Outline`. See `IconManager` in `LuaInterface.lua` for registration and cleanup methods.
