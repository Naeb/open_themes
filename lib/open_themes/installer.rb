# frozen_string_literal: true

require "fileutils"
require "pathname"

module OpenThemes
  # Writes stable stylesheet entrypoints into a Rails (or compatible) app.
  class Installer
    STYLES_DIR = %w[app assets stylesheets open_themes].freeze
    TAILWIND_DIR = %w[app assets tailwind].freeze

    def self.apply!(root:, config: OpenThemes.configuration)
      new(root: root, config: config).apply!
    end

    def initialize(root:, config: OpenThemes.configuration)
      @root = Pathname.new(root)
      @config = config
    end

    def apply!
      theme = resolve_theme_with_fallback
      write_stylesheets(theme)
      theme
    end

    def resolve_theme_with_fallback
      OpenThemes.find(@config.theme, variant: @config.variant)
    rescue OpenThemes::Catalog::NotFound => e
      handle_variant_not_found(e)
    end

    def handle_variant_not_found(error)
      return raise error unless @config.variant

      variants = available_variants_for_theme
      return raise error if variants.nil? # Theme doesn't exist

      if variants.any?
        raise_variant_error(variants)
      else
        fallback_to_default_variant
      end
    end

    def available_variants_for_theme
      catalog = OpenThemes::Catalog.new
      available_themes = catalog.all.select { |t| t.id == @config.theme.to_s }
      return nil if available_themes.empty?

      available_themes.map(&:variant).compact.sort
    end

    def raise_variant_error(variants)
      raise OpenThemes::Catalog::NotFound,
            "Variant '#{@config.variant}' not found for #{@config.theme}. Available: #{variants.join(", ")}"
    end

    def fallback_to_default_variant
      warn "Warning: Variant '#{@config.variant}' not found. Using default variant."
      OpenThemes.find(@config.theme)
    end

    def import_lines
      lines = ['@import "open_themes/theme.css";']
      lines << '@import "open_themes/foundation.css";' if @config.foundation
      lines << '@import "open_themes/components.css";' if @config.components
      lines << %(@import "open_themes/adapters/#{adapter_name}.css";) if adapter_name && adapter_name != "tailwind"
      lines
    end

    private

    def write_stylesheets(theme)
      adapter = adapter_name

      if adapter == "tailwind"
        write_tailwind_stylesheet(theme)
      else
        write_standard_stylesheets(theme, adapter)
      end
    end

    def write_tailwind_stylesheet(theme)
      tailwind_path.mkpath
      write_to_tailwind("open_themes.css", Exporters::Tailwind.export(theme, components: @config.components))
    end

    def write_standard_stylesheets(theme, adapter)
      styles_path.mkpath
      write("theme.css", Exporters::Css.export(theme))
      write("foundation.css", Assets.foundation_css) if @config.foundation
      write("components.css", Assets.components_css) if @config.components
      write_adapter_stylesheet(adapter) if adapter
    end

    def write_adapter_stylesheet(adapter)
      write(File.join("adapters", "#{adapter}.css"), Assets.adapter_css(adapter))
    end

    def adapter_name
      value = @config.adapter
      return nil if value.nil? || value.to_s.empty?

      value.to_s
    end

    def styles_path
      @root.join(*STYLES_DIR)
    end

    def tailwind_path
      @root.join(*TAILWIND_DIR)
    end

    def write(relative, contents)
      path = styles_path.join(relative)
      path.dirname.mkpath
      File.write(path, contents)
    end

    def write_to_tailwind(relative, contents)
      path = tailwind_path.join(relative)
      path.dirname.mkpath
      File.write(path, contents)
    end
  end
end
