# Salvar configurações

`LuaInterface.SaveManager` serializa valores dos controles registrados e parte do estado da janela. As chamadas de arquivo só funcionam quando o ambiente fornece as funções de filesystem usadas pelo manager; Roblox Studio padrão não oferece `readfile`/`writefile`.

## Salvar e carregar

```lua
local SaveManager = LuaInterface.SaveManager
SaveManager:SetFolder("MeuPainel")

local ok, err = SaveManager:Save("config-principal")
if not ok then
    warn("Falha ao salvar:", err)
end

local loaded, loadErr = SaveManager:Load("config-principal")
if not loaded then
    warn("Falha ao carregar:", loadErr)
end
```

Dê a cada controle persistente um identificador único. Nos métodos de grupo, ele costuma ser o primeiro argumento (`AddToggle("feature-enabled", ...)`); também é possível informar `Index` na configuração do controle.

## Pastas, lista e exportação

`SetSubFolder(name)` cria uma subpasta lógica sob a pasta definida. `List()` e `Refresh()` consultam os arquivos disponíveis quando o ambiente suporta listagem. `Delete(name)` e `Rename(oldName, newName)` alteram arquivos locais. `Export(name)` produz os dados JSON e `Import(raw, applyNow)` importa uma configuração.

`SetAutoload(name)`, `LoadAutoloadConfig()`, `StartAutoSave(name, seconds)` e `StopAutoSave()` são opcionais. Sempre verifique o retorno `(ok, err)`: disponibilidade e permissões de filesystem variam conforme o executor ou ambiente em que o cliente roda.
