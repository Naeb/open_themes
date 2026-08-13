# Changelog

## [0.2.1] - 2026-08-13

### Added

- Stable entrypoint `open_themes/theme.css` (no more manual theme import swaps)
- `config/initializers/open_themes.rb` written by the install generator
- `bin/rails open_themes:apply` regenerates CSS from configuration
- Install generator wires `@import` into `application.css` once
- Expanded upstream palette credits in README and `themes/ATTRIBUTIONS.md`

### Changed

- Switching themes = edit initializer + `open_themes:apply` (or re-run install --force)
- Project documentation standardized in English

## [0.2.0] - 2026-08-13

### Added

- Architecture docs: Core / CSS / Rails / adapters ([docs/ARCHITECTURE.md](docs/ARCHITECTURE.md))
- `foundation.css` — spacing, radius, typography scale, shadows, focus, motion, container/stack
- Bootstrap adapter (`--bs-*` ← `--ot-*`)
- Install options: `--foundation`, `--components`, `--adapter=bootstrap`

### Changed

- Reference UI moved under `stylesheets/reference/` (still optional)
- Components consume foundation tokens (no hardcoded radii/spacing)
- Positioning: design tokens for the web; components are reference only

## [0.1.1] - 2026-08-13

### Added

- Semantic tokens: `muted`, `border`, `on_primary`, `on_success`, `on_warning`, `on_danger`, `on_info`
- Optional components CSS (`.ot-btn`, `.ot-card`) with hover/active/focus/disabled
- Rails helpers `ui_button` and `ui_card`
- Install generator copies `components.css` (disable with `--no-components`)

### Changed

- CSS variables use hyphenated names (`--ot-on-primary`)

## [0.1.0] - 2026-08-13

### Added

- YAML theme schema with original palettes and semantic tokens
- Themes: Catppuccin, Tokyo Night, Nord, Dracula, Gruvbox
- `OpenThemes::Theme`, `Catalog`, `Validator`
- CSS and JSON exporters
- `bin/generate` CLI
- Rails generator `open_themes:install`
