# Configuration

`LuaInterface.SaveManager` stores and restores component values and selected UI state. It can also export/import JSON data. Filesystem operations depend on the runtime exposing compatible functions; in Roblox Studio or standard client contexts, helpers such as `writefile`, `readfile`, and `listfiles` may not exist.

## Save and load

```lua
local SaveManager = LuaInterface.SaveManager
SaveManager:SetFolder("LuaInterface")

local ok, err = SaveManager:Save("my-settings")
if not ok then
    warn("Could not save config:", err)
end

local loaded, loadErr = SaveManager:Load("my-settings")
if not loaded then
    warn("Could not load config:", loadErr)
end
```

Configuration names are sanitized by the library. Saved values include registered elements with an `Index`; give each persistent control a stable unique index (the first argument to the component method, or its `Index` option).

## Other helpers

- `SetSubFolder(name)` selects a subfolder under the configured folder.
- `List()` / `Refresh()` list available config names when supported.
- `Delete(name)` and `Rename(oldName, newName)` manage saved files.
- `Export(name)` returns JSON data for a config; `Import(raw, applyNow)` imports JSON.
- `SetAutoload(name)`, `LoadAutoloadConfig()`, `StartAutoSave(name, seconds)`, and `StopAutoSave()` provide optional autoload/automatic-save behavior.

Check the returned success value and error whenever using a filesystem-dependent method. `Export`/`Import` are useful for building an application-specific settings UI or storing data through your own trusted mechanism.
