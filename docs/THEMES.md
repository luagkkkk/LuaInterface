# Themes

LuaInterface ships with these themes: `Obsidian`, `Dark`, `Light`, `Darker`, `Amoled`, `Rose`, `Indigo`, `Blue`, `Green`, `Red`, `Purple`, `Mellowsi`, `Ocean`, `Amber`, `Emerald`, and `Violet`.

## Obsidian-inspired default

`Obsidian` is the default theme in v5.4.4. It uses graphite surfaces, soft borders, readable muted text, and a restrained violet accent. An existing saved/autoloaded theme can still override the default.

```lua
Window:SetTheme("Obsidian")
print("Current theme:", Window:GetTheme())
```

## List and apply a theme

```lua
for _, name in ipairs(LuaInterface:GetThemes()) do
    print(name)
end

LuaInterface:SetTheme("Ocean")
local ocean = LuaInterface:GetThemeData("Ocean")
```

`SetTheme(name)` applies a built-in theme. If `ApplyTheme(name)` receives an invalid name, it falls back to `Dark`; use `GetThemes()` to check available names. Custom theme tables can be registered with `RegisterTheme(name, data, baseTheme)` and then selected by name.

Theme changes update registered interface colors and tint managed icons.

## Theme tokens

Theme data exposes tokens such as `Accent`, `Background`, `Outline`, `Text`, `Placeholder`, `Button`, and `Icon`, alongside compatibility aliases used by the library (`Purple`, `Bg`, `Stroke`, `SubText`, and others).

For icons, prefer semantic color names:

```lua
LuaInterface.IconManager:Create(parent, "settings", {
    Size = 20,
    Color = "Accent",
})
```

`GetTheme()` returns the current theme name. `GetThemeData(name)` returns a copy of that theme's data.
