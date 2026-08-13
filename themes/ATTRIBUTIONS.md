# Theme attributions

OpenThemes does **not** claim ownership of the color palettes it packages.

The Ruby library, exporters, foundation CSS, adapters, and reference UI are original
work under the [MIT License](../LICENSE.txt).

Each bundled palette remains the intellectual property of its original authors and
is redistributed here under that project's license, with credit and source links
preserved in every theme YAML (`meta.attribution`, `meta.source`, `meta.license`)
and in generated CSS headers.

If you are an original author and want a credit corrected or a palette removed,
please open an issue.

---

## Catppuccin

- **Authors:** [Catppuccin Org](https://github.com/catppuccin)
- **Source:** https://github.com/catppuccin/palette
- **License:** MIT
- **Notes:** Official palette flavors (Latte, Frappé, Macchiato, Mocha).

## Tokyo Night

- **Original VS Code theme:** [enkia / tokyo-night-vscode-theme](https://github.com/enkia/tokyo-night-vscode-theme)
- **Palette values used here:** [Folke Lemaitre / tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
  (Night, Storm, Moon, Day)
- **License:** Apache-2.0 (`tokyonight.nvim`)
- **Notes:** Tokyo Night originated with enkia's VS Code theme; OpenThemes ships
  the four-style palette commonly distributed via `tokyonight.nvim`.

## Nord

- **Author:** [Sven Greb](https://www.svengreb.de) / [nordtheme](https://www.nordtheme.com)
- **Source:** https://github.com/nordtheme/nord
- **License:** MIT
- **Notes:** Official Nord palette (`nord0`–`nord15`).

## Dracula

- **Authors:** [Zeno Rocha](https://zenorocha.com) and the [Dracula Theme](https://draculatheme.com) community
- **Source:** https://github.com/dracula/dracula-theme
- **License:** MIT
- **Notes:** Classic Dracula palette from the official specification.

## Gruvbox

- **Author:** [Pavel Pertsev (morhetz)](https://github.com/morhetz)
- **Source:** https://github.com/morhetz/gruvbox
- **License:** MIT / X11 (as stated by the upstream project)
- **Notes:** Dark and light mappings derived from the official Vim color definitions.

---

## What OpenThemes adds

OpenThemes contributes:

- a shared YAML schema (original palette names + semantic tokens)
- validation, cataloging, and exporters (CSS / JSON)
- optional foundation tokens, adapters, and reference UI

Semantic token mappings (e.g. `primary → mauve`) are OpenThemes conventions for
interoperability. They are not part of the upstream theme specs unless those
projects define equivalent roles themselves.
