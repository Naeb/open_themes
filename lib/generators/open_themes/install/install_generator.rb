# frozen_string_literal: true

require "rails/generators"
require "open_themes"

module OpenThemes
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Install OpenThemes with a stable theme.css entrypoint"

      argument :theme_id, type: :string, required: true, desc: "Theme id (e.g. catppuccin)"
      argument :variant, type: :string, required: false, default: nil, desc: "Theme variant (e.g. mocha)"

      class_option :foundation, type: :boolean, default: true,
                                desc: "Install foundation structural tokens"
      class_option :components, type: :boolean, default: true,
                                desc: "Install optional reference UI components"
      class_option :adapter, type: :string, default: nil,
                             desc: "Optional adapter (bootstrap)"

      def apply_stylesheets
        sync_configuration_from_options
        theme = OpenThemes::Installer.apply!(root: destination_root, config: OpenThemes.configuration)
        say "Theme applied: #{theme.display_name} → open_themes/theme.css", :green
      rescue OpenThemes::Catalog::NotFound, ArgumentError => e
        raise Thor::Error, e.message
      end

      def create_initializer
        create_file "config/initializers/open_themes.rb", initializer_contents
      end

      def ensure_stylesheet_imports
        path = application_stylesheet_path
        return unless path

        marker = '@import "open_themes/theme.css";'
        if File.read(path).include?(marker)
          say "Stylesheet imports already present in #{path}", :green
          return
        end

        append_imports(path)
        say "Wired imports into #{path}", :green
      end

      def print_usage_hint
        say ""
        say "To switch themes later:", :green
        say "  1. Edit config/initializers/open_themes.rb"
        say "  2. Run: bin/rails open_themes:apply"
        say ""
        say "Or re-run: bin/rails generate open_themes:install nord --force"
        say "Reference helpers: <%= ui_button \"Save\", variant: :primary %>" if options[:components]
      end

      private

      def sync_configuration_from_options
        OpenThemes.configure do |config|
          config.theme = theme_id
          config.variant = blank_to_nil(variant)
          config.foundation = options[:foundation]
          config.components = options[:components]
          config.adapter = blank_to_nil(options[:adapter])
        end
      end

      def initializer_contents
        variant_ruby = ruby_value(blank_to_nil(variant))
        adapter_ruby = ruby_value(blank_to_nil(options[:adapter]))

        <<~RUBY
          # frozen_string_literal: true

          OpenThemes.configure do |config|
            config.theme = #{ruby_value(theme_id)}
            config.variant = #{variant_ruby}
            config.foundation = #{options[:foundation]}
            config.components = #{options[:components]}
            config.adapter = #{adapter_ruby}
          end
        RUBY
      end

      def ruby_value(value)
        value.nil? ? "nil" : value.to_sym.inspect
      end

      def application_stylesheet_path
        %w[
          app/assets/stylesheets/application.css
          app/assets/stylesheets/application.scss
          app/assets/stylesheets/application.css.scss
        ].map { |relative| File.join(destination_root, relative) }.find { |path| File.exist?(path) }
      end

      def append_imports(path)
        imports = OpenThemes::Installer.new(
          root: destination_root,
          config: OpenThemes.configuration
        ).import_lines.join("\n")

        File.open(path, "a") do |file|
          file.write("\n/* OpenThemes */\n#{imports}\n")
        end
      end

      def blank_to_nil(value)
        value.nil? || value.empty? ? nil : value
      end
    end
  end
end
