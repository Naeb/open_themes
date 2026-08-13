# frozen_string_literal: true

module OpenThemes
  module Exporters
    class Css
      PREFIX = "--ot"

      def self.export(theme)
        new(theme).export
      end

      def initialize(theme)
        @theme = theme
      end

      def export
        [
          header_comment,
          ":root {",
          *variable_lines,
          "}",
          ""
        ].join("\n")
      end

      private

      def header_comment
        <<~CSS.chomp
          /* OpenThemes — #{@theme.display_name}
             Source: #{@theme.meta["source"]}
             License: #{@theme.meta["license"]} — #{@theme.meta["attribution"]} */
        CSS
      end

      def variable_lines
        @theme.resolved.map do |token, hex|
          "  #{PREFIX}-#{css_token(token)}: #{hex};"
        end
      end

      def css_token(token)
        token.to_s.tr("_", "-")
      end
    end
  end
end
