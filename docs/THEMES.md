# Temas

O tema inicial da LuaInterface é **Obsidian**: superfícies grafite, bordas discretas e acento violeta. Um tema salvo e carregado automaticamente pode substituir esse padrão.

Temas incluídos: `Obsidian`, `Dark`, `Light`, `Darker`, `Amoled`, `Rose`, `Indigo`, `Blue`, `Green`, `Red`, `Purple`, `Mellowsi`, `Ocean`, `Amber`, `Emerald` e `Violet`.

## Trocar o tema

```lua
Window:SetTheme("Ocean")
print(Window:GetTheme())
```

Para listar os nomes disponíveis:

```lua
for _, name in ipairs(LuaInterface:GetThemes()) do
    print(name)
end
```

`GetTheme()` retorna o nome ativo; `GetThemeData(name)` retorna uma cópia dos dados do tema. `RegisterTheme(name, data, baseTheme)` registra uma variação própria. Se `ApplyTheme` receber um nome inválido, a biblioteca usa `Dark` como fallback.

## Cores sem valor fixo

Os dados do tema têm tokens como `Accent`, `Background`, `Outline`, `Text`, `Placeholder`, `Button` e `Icon`. Há aliases antigos (`Purple`, `Bg`, `Stroke`, `SubText`) para manter compatibilidade com controles existentes.

Use tokens em ícones e outros elementos que devam acompanhar a troca de tema:

```lua
LuaInterface.IconManager:Create(parent, "settings", {
    Size = 20,
    Color = "Accent",
})
```
