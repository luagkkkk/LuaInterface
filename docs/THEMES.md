# Themes

LuaInterface starts with **Graphite**: dark neutral surfaces, quiet borders, and a violet accent. A saved theme loaded by your script can override this default. The legacy key `Obsidian` resolves to Graphite for compatibility.

Included themes: `Graphite`, `Dark`, `Light`, `Darker`, `Amoled`, `Rose`, `Indigo`, `Blue`, `Green`, `Red`, `Purple`, `Mellowsi`, `Ocean`, `Amber`, `Emerald`, and `Violet`.

## Change the theme

```lua
Window:SetTheme("Ocean")
print(Window:GetTheme())
```

List the available names with:

```lua
for _, name in ipairs(LuaInterface:GetThemes()) do
    print(name)
end
```

`GetTheme()` returns the active theme name. `GetThemeData(name)` returns a copy of a theme's data. `RegisterTheme(name, data, baseTheme)` registers a custom variant. If `ApplyTheme` receives an invalid name, the library falls back to `Dark`.

## Use theme colors

Theme data includes tokens such as `Accent`, `Background`, `Outline`, `Text`, `Placeholder`, `Button`, and `Icon`. Compatibility aliases (`Purple`, `Bg`, `Stroke`, `SubText`) remain available for existing controls.

Use a token when an icon should follow theme changes:

```lua
LuaInterface.IconManager:Create(parent, "settings", {
    Size = 20,
    Color = "Accent",
})
```
