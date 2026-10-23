# frozen_string_literal: true

module OpenThemes
  module Exporters
    # Exports a theme as Tailwind v4 @theme block with CSS variables
    # Maps semantic tokens to Tailwind color utilities
    class Tailwind
      PREFIX = "--ot"

      COLOR_MAPPINGS = {
        # Core semantic colors
        "background" => :background,
        "surface" => :surface,
        "text" => :text,
        "muted" => :muted,
        "border" => :border,

        # Intent colors
        "primary" => :primary,
        "secondary" => :secondary,
        "success" => :success,
        "warning" => :warning,
        "danger" => :danger,
        "info" => :info,

        # On colors (for text on colored backgrounds)
        "on-primary" => :on_primary,
        "on-secondary" => :on_secondary,
        "on-success" => :on_success,
        "on-warning" => :on_warning,
        "on-danger" => :on_danger,
        "on-info" => :on_info
      }.freeze

      def self.export(theme)
        new(theme).export
      end

      def initialize(theme)
        @theme = theme
      end

      def export
        [
          header_comment,
          "@theme {",
          *theme_variables,
          "}",
          ""
        ].join("\n")
      end

      private

      def header_comment
        <<~CSS.chomp
          /* OpenThemes — #{@theme.display_name} (Tailwind adapter)
             Source: #{@theme.meta["source"]}
             License: #{@theme.meta["license"]} — #{@theme.meta["attribution"]}

             Enables classes like: bg-primary, text-muted, border-border, bg-surface, etc.
             Tokens use CSS variables so you can swap themes by regenerating this file. */
        CSS
      end

      def theme_variables
        lines = []

        # Add CSS variable definitions first
        lines << "  /* Theme tokens as CSS variables */"
        @theme.resolved.each do |token, hex|
          lines << "  #{PREFIX}-#{css_token(token)}: #{hex};"
        end

        lines << ""
        lines << "  /* Map to Tailwind color utilities */"

        # Map semantic tokens to Tailwind color names
        COLOR_MAPPINGS.each do |tailwind_name, token|
          lines << "  --color-#{tailwind_name}: var(#{PREFIX}-#{css_token(token)});" if @theme.tokens.key?(token.to_s)
        end

        lines
      end

      def css_token(token)
        token.to_s.tr("_", "-")
      end
    end
  end
end
