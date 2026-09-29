# Ícones

As abas e controles usam o `IconManager` da LuaInterface. Os vetores embutidos são desenhados com instâncias GUI do Roblox; não é preciso carregar uma imagem para cada ícone.

## Ícone em uma aba

```lua
local Reach = Window:AddTab("Reach", {
    Icon = "lucide:target",
    IconSize = 18,
})
```

Também é possível passar um nome simples (`"target"`), um ID/URI `rbxassetid://`, uma string SVG inline ou uma função renderizadora. Os prefixos `lucide:`, `tabler:` e `phosphor:` são aliases de pacotes internos: a biblioteca inclui apenas os nomes abaixo, não as coleções completas desses projetos. Um nome desconhecido usa o ícone de fallback.

## Nomes embutidos

`home`, `bell`, `alert`, `activity`, `user`, `keyboard`, `ping`, `server`, `save`, `settings`, `info`, `trash`, `arrow-right`, `x`, `dots`, `moon`, `plus`, `minus`, `check`, `search`, `menu`, `eye`, `eye-off`, `shield`, `sword`, `swords`, `target`, `crosshair`, `zap`, `play`, `pause`, `chevron-down`, `chevron-up`, `chevron-left`, `chevron-right`, `refresh`, `download`, `upload`, `copy`, `edit`, `folder`, `lock`, `unlock`, `star`, `heart`, `palette`, `sliders`, `filter`, `list`, `grid`, `smartphone`, `gamepad`, `globe`, `clock`, `volume`, `mic`, `trophy`, `users`, `package`, `database`, `terminal`, `code`, `help` e `sparkles`.

Aliases: `gear` → `settings`, `magnify` → `search`, `warning` → `alert`, `delete` → `trash` e `controls` → `sliders`.

## SVG próprio

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

Window:AddTab("Favoritos", {Icon = heart})
```

O SVG inline é interpretado pelo renderizador da LuaInterface; não é enviado diretamente para um `ImageLabel`. Há suporte para paths simples (`M`, `L`, `H`, `V`, `C`, `S`, `Q`, `T`, `A`, `Z`) e primitivas comuns (`line`, `circle`, `rect`, `polyline`, `polygon`), com `viewBox` e `stroke-width` básicos. CSS, gradientes, filtros, máscaras e transformações complexas não fazem parte do parser.

## Gerenciar ícones

```lua
local Icons = LuaInterface.IconManager
local icon = Icons:Create(parent, "tabler:swords", {Size = 20, Color = "Text"})
Icons:Tint(icon, "Accent")
Icons:SetSize(icon, 28)
Icons:RegisterAlias("favorite", "heart-outline")
```

`Color` aceita `Color3` ou tokens de tema como `Accent`, `Text`, `SubText`, `Icon`, `Button` e `Outline`. Para ver as rotinas de registro e limpeza, consulte `IconManager` em `LuaInterface.lua`.
