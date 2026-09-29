# API da LuaInterface

Este guia cobre as chamadas usadas com mais frequência na versão `1.0.0-beta`. A tabela mais completa continua sendo o próprio arquivo [`LuaInterface.lua`](../LuaInterface.lua).

## Janela

O chunk da biblioteca retorna a tabela da API:

```lua
local source = loadstring(game:HttpGet(URL))
local LuaInterface = source()

local Window = LuaInterface:CreateWindow({
    Title = "Meu painel",
    Footer = "1.0.0-beta",
    AutoShow = true,
    Resizable = true,
})
```

`CreateWindow(config)` configura a instância e retorna a própria API da janela. A interface inicia com o tema Obsidian. `Center`, `Position`, `ToggleKeybind`, `AutoShow` e `KeepDefaultTabs` podem ser informados na configuração. Por padrão, a primeira aba criada pelo script é selecionada e as páginas internas são removidas.

Chamadas comuns da janela:

```lua
Window:Open()
Window:Close()
Window:Toggle()
Window:Minimize()
Window:SetPosition(UDim2.fromScale(0.5, 0.5))
Window:SetScale(0.9)
Window:SetTheme("Obsidian")
```

`RightShift` é o atalho global padrão. Não o reutilize em um componente que também chama `Window:Toggle()`.

## Abas e áreas

```lua
local Reach = Window:AddTab("Reach", {
    Icon = "lucide:target",
    Description = "Controles de alcance",
})

local Left = Reach:AddLeftGroupbox({Name = "Ajustes"})
local Right = Reach:AddRightGroupbox({Name = "Ações"})
```

Para um ícone de aba, use um nome interno, `pack:nome`, ID de imagem, SVG inline ou função renderizadora. `IconSize` altera o tamanho do ícone. Veja [ICONS.md](ICONS.md) para os nomes disponíveis.

## Controles

### Botão e toggle

```lua
Left:AddButton({
    Text = "Restaurar",
    Func = function()
        print("ação executada")
    end,
})

local enabled = Left:AddToggle("feature-enabled", {
    Name = "Ativar recurso",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})
```

### Slider e color picker

```lua
Left:AddSlider("platform-size", {
    Name = "Tamanho da plataforma",
    Min = 2,
    Max = 30,
    Default = 8,
    Rounding = 1,
    Callback = function(value)
        print(value)
    end,
})

Left:AddColorPicker("platform-color", {
    Title = "Cor da plataforma",
    Default = Color3.fromRGB(90, 160, 255),
    Callback = function(color, transparency)
        print(color, transparency)
    end,
})
```

Os valores `Index` (ou o primeiro argumento do controle) devem ser únicos se forem usados para salvar configurações. Componentes retornam objetos de controle; os métodos disponíveis dependem do tipo e incluem `Get`, `SetValue` e `Destroy`.

## Notificações

```lua
Window:Notify({
    Type = "Success", -- Info, Success, Warning, Error, Loading, Debug, Option
    Title = "Pronto",
    Content = "As configurações foram aplicadas.",
    Duration = 3,
})
```

## Encerramento

`Window:Destroy()` ou `Window:Unload()` remove a interface e as conexões administradas pela biblioteca. Se o seu script também criou conexões próprias (por exemplo, `RunService.Heartbeat`), desconecte-as antes de destruir a janela.
