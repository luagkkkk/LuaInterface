# Changelog

Notable changes to LuaInterface are documented here.

## [5.4.6] — 2026-09-28

### Fixed

- Responsive layout now skips Home-only widgets after the built-in Home tab is removed, preventing `UpdateResp` from indexing `nil.Size` on mobile and other layouts.
- Avatar thumbnail callbacks now exit safely if Home was removed while the asynchronous request was pending.

## [5.4.5] — 2026-09-28

### Fixed

- The loaded chunk now returns the initialized API table as well as assigning `_G.LuaInterface`; `loadstring(game:HttpGet(...))()` therefore receives the library object instead of `nil`.

## [5.4.4] — 2026-09-28

### Fixed

- Bootstrap no longer silently returns `nil` when `LocalPlayer` or `PlayerGui` is unavailable; client requirements and timeout failures now produce actionable errors.
- Corrected `PlayerGui` waiting logic to use the single Instance returned by `WaitForChild`.
- Tab selection and removal no longer assume that a `Home` page always exists.
- Tab icons now consistently render through the vector/SVG icon manager, including namespaced names, inline SVG, and asset IDs.
- `Divider()` no longer depends on the removed sample page.
- Added the missing `Window:AddKeybind()` convenience method for a keybind on the currently selected tab.

### Changed

- Removed the five auto-created component demo tabs and all demo controls from the library startup.
- The first user-created tab now becomes active and removes the built-in `Home` and `Theme` tabs by default. `KeepDefaultTabs = true` preserves those system tabs.
- Added the graphite-and-violet `Obsidian` theme and made it the default.

### Documentation

- Updated the API, icon, theme, and usage examples to match the new startup behavior and supported icon subset.
- Clarified that the `lucide:`, `tabler:`, and `phosphor:` namespaces expose LuaInterface's included renderers, not the full upstream icon packs.

## [5.4.3] — 2026-09-28

### Added

- Inline SVG outline rendering for common paths and primitives, rendered as Roblox GUI objects.
- SVG-based built-in icons, including the search icon.
- `IconManager:RegisterSVG()` and direct inline-SVG support in icon registration and creation.

### Fixed

- Missing icon names inside registered namespaces now safely fall back instead of producing a nil access.
- Resizing vector-rendered icons now scales their geometry, strokes, and corners.

## [5.4.2]

### Added

- IconManager with built-in vector icon registry, aliases, namespaced resolution, asset-backed icons, and fallback behavior.
- Icon preloading and theme-aware tinting.
- Tab and groupbox icon integration.
