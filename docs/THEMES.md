# Themes

LuaInterface ships with these themes: `Dark`, `Light`, `Darker`, `Amoled`, `Rose`, `Indigo`, `Blue`, `Green`, `Red`, `Purple`, `Mellowsi`, `Ocean`, `Amber`, `Emerald`, and `Violet`.

## List and apply a theme

```lua
for _, name in ipairs(LuaInterface:GetThemes()) do
    print(name)
end

LuaInterface:SetTheme("Ocean")
print("Current theme:", LuaInterface:GetTheme())
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
