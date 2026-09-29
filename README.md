# LuaInterface

**Versão atual: `1.0.0-beta`** · Biblioteca de interface para Roblox, escrita em Luau.

LuaInterface fornece a camada de interface para scripts Roblox: janela responsiva, abas, groupboxes, controles, temas e ícones vetoriais renderizados com objetos GUI. O tema inicial é **Obsidian** (grafite com acento violeta).

## Carregar a biblioteca

Em um cliente que permita HTTP e `loadstring`:

```lua
local source, err = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/luagkkkk/LuaInterface/main/LuaInterface.lua"
))
assert(source, err)

local LuaInterface = source()
assert(type(LuaInterface) == "table", "LuaInterface não inicializou")
```

O código precisa rodar no cliente, com `Players.LocalPlayer` e `PlayerGui` disponíveis. Em um projeto Roblox Studio que não permite `loadstring`, coloque o arquivo em um `ModuleScript` confiável e carregue-o por um `LocalScript`. Recursos de arquivo como `readfile` e `writefile` dependem do ambiente e não são necessários para abrir a interface.

## Exemplo mínimo

```lua
local Window = LuaInterface:CreateWindow({
    Title = "Meu painel",
    Footer = "LuaInterface 1.0.0-beta",
    AutoShow = true,
})

local Reach = Window:AddTab("Reach", {
    Icon = "lucide:target",
    Description = "Controles de alcance",
})

local Controls = Reach:AddLeftGroupbox({Name = "Ajustes"})

Controls:AddToggle("reach-enabled", {
    Name = "Ativar",
    Default = false,
    Callback = function(enabled)
        print("Reach:", enabled)
    end,
})

Controls:AddSlider("reach-size", {
    Name = "Tamanho",
    Min = 1,
    Max = 20,
    Default = 4,
    Rounding = 1,
    Callback = function(value)
        print("Tamanho:", value)
    end,
})
```

A primeira aba criada pelo script fica selecionada; as páginas de demonstração não são inseridas na janela. Para manter as páginas internas `Home` e `Theme`, passe `KeepDefaultTabs = true` em `CreateWindow`.

## Tecla do menu

`RightShift` é o atalho global padrão para abrir/fechar a janela. Não registre outra ação em `RightShift` que também chame `Window:Toggle()`: isso provoca dois toggles no mesmo pressionamento. Use outra tecla para um keybind de componente ou defina `ToggleKeybind` ao criar a janela.

## Ícones e aparência

As abas aceitam nomes como `lucide:target`, IDs de imagem Roblox e SVG inline simples. Os pacotes `lucide:`, `tabler:` e `phosphor:` apontam para o subconjunto incluído neste projeto; não são cópias completas dessas coleções. Consulte [ícones](docs/ICONS.md) e [temas](docs/THEMES.md).

## Documentação e exemplos

- [API de janela, abas e controles](docs/API.md)
- [Ícones e SVG](docs/ICONS.md)
- [Temas](docs/THEMES.md)
- [Salvar e carregar configurações](docs/CONFIG.md)
- [Exemplos Lua](examples/), incluindo [HitboxExpander com as abas Reach e Helper](examples/HitboxExpander.lua)

## Estado do projeto

Esta é uma versão beta. A sintaxe dos arquivos é verificada antes das atualizações; a validação visual e de interação deve ser feita no Roblox Studio ou no cliente-alvo. Relate erros com a versão usada e a mensagem completa do console.

## Licença

MIT. Consulte [LICENSE](LICENSE).
