# OpenThemes

Design themes and semantic tokens for the web.  
Rails is a first-class integration — not the whole product.

Normalize community palettes (Catppuccin, Tokyo Night, Nord, …) into shared `--ot-*` tokens.
Optionally consume a thin **reference UI**, or map Bootstrap / custom CSS / any stack onto the same tokens.

```
Theme palette  →  semantic tokens  →  CSS variables  →  your UI
                                      ↘ adapters (Bootstrap, …)
                                      ↘ reference components (optional)
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Themes

Bundled palettes come from the community. OpenThemes only normalizes them into
shared semantic tokens — please credit the original authors when you redistribute
a theme.

| Theme | Variants | Original authors | License |
|-------|----------|------------------|---------|
| Catppuccin | latte, frappe, macchiato, mocha | [Catppuccin Org](https://github.com/catppuccin) | MIT |
| Tokyo Night | night, storm, moon, day | [enkia](https://github.com/enkia/tokyo-night-vscode-theme) (original), [Folke Lemaitre](https://github.com/folke/tokyonight.nvim) | Apache-2.0 |
| Nord | — | [Sven Greb / nordtheme](https://github.com/nordtheme/nord) | MIT |
| Dracula | — | [Zeno Rocha](https://draculatheme.com) & Dracula Theme | MIT |
| Gruvbox | dark, light | [Pavel Pertsev (morhetz)](https://github.com/morhetz/gruvbox) | MIT / X11 |

Full credits, sources, and notes: **[themes/ATTRIBUTIONS.md](themes/ATTRIBUTIONS.md)**.

## Semantic tokens

| Token | CSS |
|-------|-----|
| `background` / `surface` | `--ot-background` / `--ot-surface` |
| `text` / `muted` / `border` | `--ot-text` / `--ot-muted` / `--ot-border` |
| `primary` … `info` | `--ot-primary` … `--ot-info` |
| `on_primary` … `on_info` | `--ot-on-primary` … `--ot-on-info` |

Foundation (structural, theme-agnostic): spacing, radius, type scale, shadows, focus, motion — see `foundation.css`.

## Installation

```ruby
gem "open_themes"
```

## Minimal usage (tokens only)

```ruby
theme = OpenThemes.find(:catppuccin, variant: :mocha)
puts OpenThemes::Exporters::Css.export(theme)
```

```bash
bin/generate catppuccin mocha -o theme.css
```

```css
@import "theme.css";
@import "open_themes/foundation.css"; /* optional */

.btn-primary {
  background: var(--ot-primary);
  color: var(--ot-on-primary);
}
```

Any framework can mirror tokens — no helpers or `.ot-btn` required.

## Rails

### Install once

```bash
rails generate open_themes:install catppuccin mocha
```

This will:

1. Generate `app/assets/stylesheets/open_themes/theme.css` (stable path)
2. Generate foundation/components based on flags
3. Create `config/initializers/open_themes.rb`
4. Wire `@import` into `application.css` **once** (if not already present)

After that, `application.css` stays fixed:

```css
@import "open_themes/theme.css";
@import "open_themes/foundation.css";
@import "open_themes/components.css";
```

### Switch themes (without editing CSS)

Edit the initializer:

```ruby
OpenThemes.configure do |config|
  config.theme = :nord
  config.variant = nil
end
```

Apply:

```bash
bin/rails open_themes:apply
```

Or regenerate directly:

```bash
bin/rails generate open_themes:install nord --force
```

Both rewrite `theme.css` (and the initializer, when using the generator). `application.css` does not need to change again.

Flags:

```bash
rails generate open_themes:install catppuccin mocha --adapter=bootstrap
rails generate open_themes:install nord --no-components
```

### Reference UI (optional)

```erb
<%= ui_card do %>
  <h1 class="ot-card__title">OpenThemes</h1>
  <p class="ot-card__body">Tokens first. Components optional.</p>
  <div class="ot-card__actions">
    <%= ui_button "Save", variant: :primary %>
    <%= ui_button "Cancel", variant: :outline %>
  </div>
<% end %>
```

Variants: `primary`, `success`, `warning`, `danger`, `info`, `outline`, `ghost`.  
Sizes: `sm`, `md`, `lg`.

## Adapters

| Adapter | What it does |
|---------|--------------|
| `bootstrap` | `--bs-primary` ← `var(--ot-primary)`, body/border/link, etc. |
| `tailwind` | Maps tokens to Tailwind v4 utilities: `bg-primary`, `text-muted`, `border-border`, etc. |

### Tailwind v4 Integration

OpenThemes supports Tailwind v4 (Rails 8+) through `@theme inline` blocks that enable runtime theme switching.

**Requirements**: Rails 8+ with `tailwindcss-rails` (Tailwind v4). Not compatible with Tailwind v3.

#### Installation (2 commands)

```bash
# 1. Install theme
rails generate open_themes:install catppuccin mocha --adapter tailwind

# 2. Build Tailwind
bin/rails tailwindcss:build
```

#### How it works

The generator creates `app/assets/tailwind/open_themes.css` with:

1. **`:root` block** with CSS variables (`--ot-background`, `--ot-primary`, etc.)
2. **`@theme inline` block** mapping variables to Tailwind colors

This structure allows runtime theme switching by updating `--ot-*` variables without rebuilding Tailwind.

The file is automatically imported into `app/assets/tailwind/application.css`:

```css
@import "tailwindcss";

/* OpenThemes:begin */
@import "./open_themes.css";
/* OpenThemes:end */
```

#### Available classes

Once installed, use Tailwind utilities with semantic token colors:

| Token | Example classes |
|-------|----------------|
| `primary` | `bg-primary`, `text-primary`, `border-primary` |
| `surface` | `bg-surface`, `text-surface` |
| `text` | `text-text` |
| `muted` | `text-muted` |
| `border` | `border-border` |
| `success` | `bg-success`, `text-success` |
| `warning` | `bg-warning`, `text-warning` |
| `danger` | `bg-danger`, `text-danger` |
| `info` | `bg-info`, `text-info` |
| `on-*` | `text-on-primary`, `text-on-success` (for text on colored backgrounds) |

#### Switching themes

Edit `config/initializers/open_themes.rb`:

```ruby
OpenThemes.configure do |config|
  config.theme = :nord  # Changed from :catppuccin
  config.adapter = :tailwind
end
```

Then regenerate:

```bash
bin/rails open_themes:apply
bin/rails tailwindcss:build
```

The Tailwind entrypoint stays unchanged — only token values are updated.

#### Reference components (optional)

By default, `--adapter tailwind` skips foundation and components. To include Tailwind-compatible component styles:

```bash
rails generate open_themes:install catppuccin mocha --adapter tailwind --components
```

This adds `.ot-btn`, `.ot-card`, etc. using `@apply` directives. Helpers (`ui_button`, `ui_card`) work as documented below.

## CLI

```bash
bin/generate catppuccin mocha
bin/generate nord --format json
bin/generate tokyo-night storm -o theme.css
```

## Development

```bash
bin/setup
bundle exec rake spec
bundle exec rubocop
```

## License

The OpenThemes gem (code, exporters, foundation, adapters, reference UI) is
available under the [MIT License](LICENSE.txt).

**Bundled color palettes remain under their upstream licenses** and belong to
their original authors. See [themes/ATTRIBUTIONS.md](themes/ATTRIBUTIONS.md).
Generated CSS includes per-theme attribution headers for redistribution.
