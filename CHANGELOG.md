# Changelog

## [Unreleased]

### Fixed

- **BREAKING BUG FIX**: Renamed internal `class_names` helper to `ot_merge_classes` (private) to prevent overriding Rails native `ActionView::Helpers::TagHelper#class_names`. The gem was breaking views that use `class_names("a", {"b" => true, "c" => false})` by converting hashes to strings instead of filtering truthy values. Public helpers (`ui_button`, `ui_card`) unchanged.

### Added

- **Tailwind v4 adapter** for Rails 8+ with `tailwindcss-rails`:
  - Generates `app/assets/tailwind/open_themes.css` with `:root` variables and `@theme inline` block
  - Enables runtime theme switching without rebuilding Tailwind (update CSS vars only)
  - Auto-imports into `app/assets/tailwind/application.css` with managed markers (idempotent)
  - Maps semantic tokens to Tailwind utilities: `bg-primary`, `text-muted`, `border-border`, etc.
  - Optional components with `@apply` directives (`.ot-btn`, `.ot-card`)
  - Install: `rails g open_themes:install theme --adapter tailwind`
  - Switch themes: Edit initializer + `bin/rails open_themes:apply` + `tailwindcss:build`
  
### Changed

- Tailwind v3 (`application.tailwind.css` entrypoint) is not supported by the adapter; use Tailwind v4 (Rails 8+) only
- Generator validates adapter option and exits with non-zero status for invalid values
- In Tailwind mode, generator only touches Tailwind entrypoint (not `application.css`)

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
