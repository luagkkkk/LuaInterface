# Icons

LuaInterface's `IconManager` resolves built-in vector icons, aliases, renderer functions, image assets, and inline SVG markup. Built-in vectors and parsed SVGs are drawn with Roblox GUI objects, so they do not require one uploaded image asset per icon.

## Use an icon in a tab

The tab API accepts the WindUI-style `pack:name` form for names in LuaInterface's included subset, along with a plain built-in name, an asset ID/URI, raw inline SVG, or a renderer function:

```lua
local Tab = Window:AddTab("Settings", {
    Icon = "lucide:settings",
    IconSize = 18,
})
```

`lucide:`, `tabler:`, and `phosphor:` are registered namespaces that point to LuaInterface's own icon subset. They are **not** the full official Lucide, Tabler, or Phosphor collections. An unrecognized namespaced icon falls back to the default dots icon rather than displaying its raw name as text.

## Built-in icon names

The included names are:

`home`, `bell`, `alert`, `activity`, `user`, `keyboard`, `ping`, `server`, `save`, `settings`, `info`, `trash`, `arrow-right`, `x`, `dots`, `moon`, `plus`, `minus`, `check`, `search`, `menu`, `eye`, `eye-off`, `shield`, `sword`, `swords`, `target`, `crosshair`, `zap`, `play`, `pause`, `chevron-down`, `chevron-up`, `chevron-left`, `chevron-right`, `refresh`, `download`, `upload`, `copy`, `edit`, `folder`, `lock`, `unlock`, `star`, `heart`, `palette`, `sliders`, `filter`, `list`, `grid`, `smartphone`, `gamepad`, `globe`, `clock`, `volume`, `mic`, `trophy`, `users`, `package`, `database`, `terminal`, `code`, `help`, and `sparkles`.

Aliases include `gear` → `settings`, `magnify` → `search`, `warning` → `alert`, `delete` → `trash`, and `controls` → `sliders`.

## IconManager

```lua
local Icons = LuaInterface.IconManager

print(Icons:Exists("settings"))
print(Icons:Exists("lucide:settings"))

local icon = Icons:Create(parent, "tabler:swords", {
    Size = 20,
    Color = "Accent",
})
```

`Color` accepts a `Color3` or theme names such as `Accent`, `Text`, `SubText`, `Icon`, `Button`, and `Outline`. Registered icons are tracked for theme tinting and cleanup. Numeric IDs and `rbxassetid://...` strings are accepted as image assets.

## Registering and rendering SVG

```lua
local Icons = LuaInterface.IconManager

local heartSvg = [[
<svg viewBox="0 0 24 24">
  <path d="M20 8 C20 4 15 3 12 8 C9 3 4 4 4 8 C4 13 12 20 12 20 C12 20 20 13 20 8 Z"/>
</svg>
]]

Icons:RegisterSVG("heart-outline", heartSvg)
local icon = Icons:Create(parent, "heart-outline", {Size = 22, Color = "Accent"})

-- SVG can also be placed directly on a tab:
local CustomTab = Window:AddTab("Custom", {Icon = heartSvg})
```

`RegisterPack(name, icons)` accepts renderer functions, asset identifiers, and SVG strings. A custom tab can also receive `Icon = function(parent, size) return myGuiObject end`.

## Managing an icon

```lua
Icons:Tint(icon, "Text")
Icons:SetSize(icon, 28)
Icons:RegisterAlias("favorite", "heart-outline")
Icons:Remove("heart-outline")
```

## SVG support and limitations

Roblox `ImageLabel` does not display arbitrary SVG markup. LuaInterface parses supported outline markup and draws it as native GUI objects. Supported path commands include absolute and relative `M`, `L`, `H`, `V`, `C`, `S`, `Q`, `T`, `A`, and `Z`. Common `line`, `circle`, `rect`, `polyline`, and `polygon` elements are also recognized, along with a basic `viewBox` and `stroke-width`.

This is a lightweight icon renderer, **not a complete SVG/CSS engine**. SVG transforms, stylesheets, gradients, filters, masks, and filled arbitrary paths are not fully supported. For best results, use simple monochrome outline icons with explicit path data and a square `viewBox`.
