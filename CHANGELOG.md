# Changelog

## `1.1.0-beta` — published, 2026-09-29

This release adapts public-facing API patterns from the user-provided WindUI `v1.6.65` reference bundle to LuaInterface's own components and lifecycle. This is an independent adapter, not the reference library or its remote loader.

### Added

- WindUI-shaped window, tab, section, group, and stack calls while preserving existing `CreateWindow`, `AddTab`, and groupbox methods.
- Missing local elements identified in the reference: `Paragraph`, `ProgressBar`, `Image`, `Code`, `Space`, `Group`, `HStack`, `VStack`, and `Viewport`.
- Theme aliases, custom theme registration, theme tags, and change callbacks.
- Shape sprite-sheet helper using the shape names and Roblox asset IDs found in the provided bundle.
- Icon-manager use in window headers and notifications; no remote icon registry or loader is used.
- Notification message/action aliases and top/bottom placement controls.
- Optional projected-glass Acrylic approximation with lifecycle cleanup and restoration of captured depth-of-field values.
- [`examples/WindUICompat.lua`](examples/WindUICompat.lua) and a detailed compatibility/boundaries guide.

### Fixed / checked locally

- Added vertical `UIListLayout` to each HStack column so multiple controls do not overlap.
- Normalized Multi-select callback values to an array.
- Made notification aliases safe with both dot and colon calls.
- Made Acrylic module teardown safe when the existing destroy manager invokes module callbacks without `self`.
- Centered vector and SVG icon canvases by default, including groupbox headers; replaced the rough Save glyph with the supplied outline SVG.
- Validated Lua syntax and whitespace locally.

Roblox client behavior, Acrylic appearance/performance, input interactions, and asset availability still need testing in the target client.

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

- Added tabs, examples, SVG registration, the Graphite theme (the prior theme identifier remains a compatibility alias), first-custom-tab selection, and `Window:AddKeybind`.
