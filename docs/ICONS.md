# Icons

LuaInterface's `IconManager` resolves named icons, aliases, renderer functions, image assets, and inline SVG markup. Built-in vector artwork is rendered with Roblox GUI objects, so it does not require one uploaded image asset per icon.

## Built-in icons

The current registry includes names such as:

`home`, `bell`, `alert`, `activity`, `user`, `keyboard`, `ping`, `server`, `save`, `settings`, `info`, `trash`, `arrow-right`, `x`, `dots`, `moon`, `plus`, `minus`, `check`, `search`, `menu`, `eye`, `eye-off`, `shield`, `sword`, `swords`, `target`, `crosshair`, `zap`, `play`, `pause`, `chevron-down`, `chevron-up`, `chevron-left`, `chevron-right`, `refresh`, `download`, `upload`, `copy`, `edit`, `folder`, `lock`, `unlock`, `star`, `heart`, `palette`, `sliders`, `filter`, `list`, `grid`, `smartphone`, `gamepad`, `globe`, `clock`, `volume`, `mic`, `trophy`, `users`, `package`, `database`, `terminal`, `code`, `help`, and `sparkles`.

Aliases include `gear` → `settings`, `magnify` → `search`, `warning` → `alert`, and `delete` → `trash`.

## Namespaces

```lua
local Icons = LuaInterface.IconManager

print(Icons:Exists("settings"))
print(Icons:Exists("lucide:settings"))

local icon = Icons:Create(parent, "tabler:swords", {
    Size = 20,
    Color = "Accent",
})
```

The `lucide:`, `tabler:`, and `phosphor:` namespaces resolve the library's registered renderers. They are **not** bundled official Lucide, Tabler, or Phosphor icon packages.

## Registering an SVG icon

```lua
local Icons = LuaInterface.IconManager

Icons:RegisterSVG("heart-outline", [[
<svg viewBox="0 0 24 24">
  <path d="M20 8 C20 4 15 3 12 8 C9 3 4 4 4 8 C4 13 12 20 12 20 C12 20 20 13 20 8 Z"/>
</svg>
]])

local icon = Icons:Create(parent, "heart-outline", {
    Size = 22,
    Color = "Accent",
})
```

An SVG can also be passed directly to `Create`, or registered with `Register(name, svgMarkup)`. `RegisterPack(name, icons)` accepts renderer functions, asset identifiers, and SVG strings.

## Managing an icon

```lua
Icons:Tint(icon, "Text")
Icons:SetSize(icon, 28)
Icons:RegisterAlias("favorite", "heart-outline")
Icons:Remove("heart-outline")
```

`Color` accepts a `Color3` or theme names such as `Accent`, `Text`, `SubText`, `Icon`, `Button`, and `Outline`. Icons registered through the manager are tracked for theme tinting and cleanup.

## SVG support and limitations

Roblox `ImageLabel` does not display arbitrary SVG markup. LuaInterface parses supported outline markup and draws it as native GUI objects.

Supported path commands include absolute and relative `M`, `L`, `H`, `V`, `C`, `S`, `Q`, `T`, `A`, and `Z`. Common `line`, `circle`, `rect`, `polyline`, and `polygon` elements are also recognized, along with a basic `viewBox` and `stroke-width`.

This is intentionally a lightweight icon renderer, **not a complete SVG/CSS engine**. SVG transforms, stylesheets, gradients, filters, masks, and filled arbitrary paths are not fully supported. For best results, use simple monochrome outline icons with explicit path data and a square `viewBox`.
