# Changelog

## `1.1.1-beta` — published, 2026-09-29

- Added the requested open, close, bell, and maximize SVG icons to the window controls and default notifications.
- Centered SVG canvases and their drawing layers; replaced the logo image fallback on the Open button.
- Kept the Home avatar slot visible while the player thumbnail loads, with retries and a vector placeholder.
- Renamed the component demonstration to `examples/Showcase.lua`; it replaces the built-in pages and includes a SaveManager test page.
- Reworked compatibility documentation and consolidated source attribution under `docs/THIRD_PARTY_NOTICES.md`.
- Static syntax checks pass. Avatar retrieval, input, Acrylic blur, and Roblox rendering still need testing in a client.

## `1.1.0-beta` — published, 2026-09-29

Added an API adapter for window, tab, section, group, element, theme, shape, icon, and notification calls. Existing LuaInterface methods remain available.

### Added

- Window, tab, section, group, and stack helpers.
- `Paragraph`, `ProgressBar`, `Image`, `Code`, `Space`, `Group`, `HStack`, `VStack`, and `Viewport` elements.
- Theme aliases, custom theme registration, theme tags, and change callbacks.
- Shape sprite-sheet helper using local registrations.
- Icon-manager support in window headers, notifications, groupbox headers, and controls.
- Notification message/action aliases and top/bottom placement controls.
- Optional projected-glass Acrylic approximation with lifecycle cleanup and restoration of captured depth-of-field values.
- Compatibility guide and component examples.

### Fixed / checked locally

- Added vertical `UIListLayout` to each HStack column so multiple controls do not overlap.
- Normalized Multi-select callback values to an array.
- Made notification aliases safe with both dot and colon calls.
- Made Acrylic module teardown safe when the destroy manager invokes callbacks without `self`.
- Centered vector and SVG icon canvases by default, including groupbox headers.
- Validated Lua syntax and whitespace.

Roblox client behavior, Acrylic appearance/performance, input interactions, and asset availability still require testing in the target client/Studio.

## `1.0.0-beta` — 2026-09-29

First beta release under the 1.0 version line. This release keeps the existing LuaInterface API and documents its current behavior and examples.

- README and guides describe the window, tabs, controls, icons, themes, and configuration helpers.
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

- Added tabs, examples, SVG registration, the Graphite theme, first-custom-tab selection, and `Window:AddKeybind`.
