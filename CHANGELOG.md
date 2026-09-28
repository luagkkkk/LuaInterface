# Changelog

Notable changes to LuaInterface are documented here.

## [5.4.3] — 2026-09-28

### Added

- Inline SVG outline rendering for common paths and primitives, rendered as Roblox GUI objects.
- SVG-based built-in icons, including the search icon.
- `IconManager:RegisterSVG()` and direct inline-SVG support in icon registration and creation.

### Fixed

- Missing icon names inside registered namespaces now safely fall back instead of producing a nil access.
- Resizing vector-rendered icons now scales their geometry, strokes, and corners.

### Improved

- Added public-facing documentation and usage examples for the icon, theme, and configuration systems.
- Clarified that the `lucide:`, `tabler:`, and `phosphor:` namespaces resolve LuaInterface renderers; they do not bundle those projects' official icon libraries.

## [5.4.2]

### Added

- IconManager with built-in vector icon registry, aliases, namespaced resolution, asset-backed icons, and fallback behavior.
- Icon preloading and theme-aware tinting.
- Tab and groupbox icon integration.

### Improved

- Icon cleanup, resolution, and fallback behavior.
