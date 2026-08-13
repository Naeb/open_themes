# Architecture

OpenThemes has independent layers. Themes must work without components.

```
open_themes
│
├── Core
│   ├── themes/*.yml      # original palettes
│   ├── semantic tokens   # background, primary, danger, …
│   └── Theme / Catalog / Validator
│
├── CSS
│   ├── theme export      # --ot-* color tokens
│   ├── foundation        # spacing, radius, type, focus, motion
│   ├── adapters/         # Bootstrap, (Tailwind later), …
│   └── reference/        # optional demo components (.ot-btn, .ot-card)
│
└── Rails
    ├── helpers           # thin wrappers around reference UI
    └── generators
```

## Golden rules

1. **No theme-specific hex in components or adapters.** Only `var(--ot-…)`.
2. **Components are optional reference UI**, not the product.
3. **Adapters bridge existing frameworks** to tokens (e.g. `--bs-primary: var(--ot-primary)`).
4. **Accessibility from the first component**: contrast via `on_*` tokens, `:focus-visible`, disabled states.

## Typical consumption modes

### Tokens only (any stack)

```css
@import "open_themes/theme.css";
@import "open_themes/foundation.css";

.btn-primary {
  background: var(--ot-primary);
  color: var(--ot-on-primary);
}
```

### Existing Bootstrap app

```css
@import "open_themes/theme.css";
@import "open_themes/adapters/bootstrap.css";
```

### Reference UI + Rails helpers

```css
@import "open_themes/theme.css";
@import "open_themes/foundation.css";
@import "open_themes/components.css";
```

```erb
<%= ui_button "Save", variant: :primary %>
```

## Component roadmap (reference UI)

Ship slowly. Prefer validating tokens + adapters over growing a closed design system.

Suggested order after Button/Card:

1. Alert, Badge
2. Field / Input / Textarea / Select
3. Table, Pagination
4. Modal, Tabs

Forms helpers should stay thin (`ui_button`, later field wrappers) — not a large DSL.

## Credits

Palette colors are redistributed from community projects with attribution.
See [themes/ATTRIBUTIONS.md](../themes/ATTRIBUTIONS.md). OpenThemes owns the
token schema and tooling, not the original palettes.
