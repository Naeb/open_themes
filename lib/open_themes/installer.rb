# frozen_string_literal: true

require "fileutils"
require "pathname"

module OpenThemes
  # Writes stable stylesheet entrypoints into a Rails (or compatible) app.
  class Installer
    STYLES_DIR = %w[app assets stylesheets open_themes].freeze

    def self.apply!(root:, config: OpenThemes.configuration)
      new(root: root, config: config).apply!
    end

    def initialize(root:, config: OpenThemes.configuration)
      @root = Pathname.new(root)
      @config = config
    end

    def apply!
      theme = OpenThemes.find(@config.theme, variant: @config.variant)
      write_stylesheets(theme)
      theme
    end

    def import_lines
      lines = ['@import "open_themes/theme.css";']
      lines << '@import "open_themes/foundation.css";' if @config.foundation
      lines << '@import "open_themes/components.css";' if @config.components
      lines << %(@import "open_themes/adapters/#{adapter_name}.css";) if adapter_name
      lines
    end

    private

    def write_stylesheets(theme)
      styles_path.mkpath

      adapter = adapter_name

      if adapter == "tailwind"
        # For Tailwind, generate a @theme block instead of standard CSS
        write("tailwind.css", Exporters::Tailwind.export(theme))
      else
        # Standard CSS variables approach
        write("theme.css", Exporters::Css.export(theme))
        write("foundation.css", Assets.foundation_css) if @config.foundation
        write("components.css", Assets.components_css) if @config.components
        write_adapter_stylesheet if adapter && adapter != "tailwind"
      end
    end

    def write_adapter_stylesheet
      return unless adapter_name

      write(File.join("adapters", "#{adapter_name}.css"), Assets.adapter_css(adapter_name))
    end

    def adapter_name
      value = @config.adapter
      return nil if value.nil? || value.to_s.empty?

      value.to_s
    end

    def styles_path
      @root.join(*STYLES_DIR)
    end

    def write(relative, contents)
      path = styles_path.join(relative)
      path.dirname.mkpath
      File.write(path, contents)
    end
  end
end
