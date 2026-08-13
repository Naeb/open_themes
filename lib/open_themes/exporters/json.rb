# frozen_string_literal: true

require "json"

module OpenThemes
  module Exporters
    class Json
      def self.export(theme)
        new(theme).export
      end

      def initialize(theme)
        @theme = theme
      end

      def export
        payload = {
          "id" => @theme.id,
          "variant" => @theme.variant,
          "name" => @theme.name,
          "variant_name" => @theme.variant_name,
          "appearance" => @theme.appearance,
          "meta" => @theme.meta,
          "palette" => @theme.palette,
          "tokens" => @theme.tokens,
          "resolved" => @theme.resolved
        }
        "#{JSON.pretty_generate(payload)}\n"
      end
    end
  end
end
