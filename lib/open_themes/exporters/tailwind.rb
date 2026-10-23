# frozen_string_literal: true

module OpenThemes
  module Exporters
    # Exports a theme as Tailwind v4 @theme inline block with CSS variables
    # Maps semantic tokens to Tailwind color utilities
    class Tailwind
      PREFIX = "--ot"

      COLOR_MAPPINGS = {
        "background" => :background,
        "surface" => :surface,
        "text" => :text,
        "muted" => :muted,
        "border" => :border,
        "primary" => :primary,
        "success" => :success,
        "warning" => :warning,
        "danger" => :danger,
        "info" => :info,
        "on-primary" => :on_primary,
        "on-success" => :on_success,
        "on-warning" => :on_warning,
        "on-danger" => :on_danger,
        "on-info" => :on_info
      }.freeze

      def self.export(theme, components: false)
        new(theme, components: components).export
      end

      def initialize(theme, components: false)
        @theme = theme
        @components = components
      end

      def export
        parts = [header_comment, "", root_variables, "", theme_block]
        parts << "" << components_css if @components
        parts << ""
        parts.join("\n")
      end

      private

      def header_comment
        <<~CSS.chomp
          /* OpenThemes — #{@theme.display_name} (Tailwind v4 adapter)
             Source: #{@theme.meta["source"]}
             License: #{@theme.meta["license"]} — #{@theme.meta["attribution"]}

             Enables Tailwind utilities: bg-primary, text-muted, border-border, etc.
             @theme inline allows overriding --ot-* CSS variables for runtime switching. */
        CSS
      end

      def root_variables
        lines = [":root {"]
        @theme.resolved.each do |token, hex|
          lines << "  #{PREFIX}-#{css_token(token)}: #{hex};"
        end
        lines << "}"
        lines.join("\n")
      end

      def theme_block
        lines = ["@theme inline {"]
        COLOR_MAPPINGS.each do |tailwind_name, token|
          lines << "  --color-#{tailwind_name}: var(#{PREFIX}-#{css_token(token)});" if @theme.tokens.key?(token.to_s)
        end
        lines << "}"
        lines.join("\n")
      end

      def components_css
        File.read(components_path)
      end

      def components_path
        Pathname.new(__dir__).join("../stylesheets/reference/tailwind_components.css")
      end

      def css_token(token)
        token.to_s.tr("_", "-")
      end
    end
  end
end
