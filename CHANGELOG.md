# Changelog

## [1.0.0-beta] — 2026-09-29

First beta release under the 1.0 version line. This release keeps the existing LuaInterface API and documents its current behavior and examples.

- README and guides now describe the window, tabs, controls, icons, themes, and configuration helpers.
- No intentional changes to public method names in this beta.

## History before the beta

### 5.4.8 — 2026-09-28

- `SetScale()` scales the window rather than the full `ScreenGui`; centering uses relative positioning.
- The global menu key no longer triggers a duplicate component keybind.
- Mouse and touch dragging are available from the header/title area.

### 5.4.7 — 2026-09-28

- Initial layout waits for the camera's valid `ViewportSize` and preserves a position set by the script.

### 5.4.6 — 2026-09-28

- Layout skips removed Home widgets, and the asynchronous avatar callback checks that its page still exists.

### 5.4.5 — 2026-09-28

- The library chunk returns its API table when loaded with `loadstring`.

### 5.4.4 — 2026-09-28

- Added tabs, examples, SVG registration, the Obsidian theme, first-custom-tab selection, and `Window:AddKeybind`.
