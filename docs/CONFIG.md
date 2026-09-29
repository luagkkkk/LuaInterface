# Saving configurations

`LuaInterface.SaveManager` stores registered control values and some window state. File operations require the runtime to expose compatible filesystem functions; standard Roblox Studio does not provide `readfile` or `writefile`.

## Save and load

```lua
local SaveManager = LuaInterface.SaveManager
SaveManager:SetFolder("MyPanel")

local ok, err = SaveManager:Save("main-config")
if not ok then
    warn("Could not save:", err)
end

local loaded, loadErr = SaveManager:Load("main-config")
if not loaded then
    warn("Could not load:", loadErr)
end
```

Give each persistent control a unique identifier. For group methods, this is usually the first argument (`AddToggle("feature-enabled", ...)`); you can also set `Index` in the control config.

## Folders, listing, and export

`SetSubFolder(name)` selects a subfolder under the configured folder. `List()` and `Refresh()` query available files when the runtime supports listing. `Delete(name)` and `Rename(oldName, newName)` modify local files. `Export(name)` returns JSON data, and `Import(raw, applyNow)` imports it.

`SetAutoload(name)`, `LoadAutoloadConfig()`, `StartAutoSave(name, seconds)`, and `StopAutoSave()` are optional helpers. Check the returned `(ok, err)` values: filesystem support and permissions depend on the client environment.
