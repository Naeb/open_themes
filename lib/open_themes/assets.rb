# frozen_string_literal: true

require "pathname"

module OpenThemes
  module Assets
    ADAPTERS = %w[bootstrap].freeze

    module_function

    def stylesheets_path
      Pathname.new(__dir__).join("stylesheets")
    end

    def foundation_css_path
      stylesheets_path.join("foundation.css")
    end

    def components_css_path
      stylesheets_path.join("reference", "components.css")
    end

    def adapter_css_path(name)
      stylesheets_path.join("adapters", "#{name}.css")
    end

    def foundation_css
      File.read(foundation_css_path)
    end

    def components_css
      File.read(components_css_path)
    end

    def adapter_css(name)
      name = name.to_s
      raise ArgumentError, "unknown adapter: #{name}" unless ADAPTERS.include?(name)

      File.read(adapter_css_path(name))
    end
  end
end
