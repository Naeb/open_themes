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
                             desc: "Optional adapter (bootstrap, tailwind)"

      def apply_stylesheets
        sync_configuration_from_options
        validate_adapter_option!
        theme = OpenThemes::Installer.apply!(root: destination_root, config: OpenThemes.configuration)

        adapter = options[:adapter]&.to_s
        if adapter == "tailwind"
          say "Theme applied: #{theme.display_name} → app/assets/tailwind/open_themes.css", :green
        else
          say "Theme applied: #{theme.display_name} → open_themes/theme.css", :green
        end
      rescue OpenThemes::Catalog::NotFound, ArgumentError => e
        raise Thor::Error, e.message
      end

      def create_initializer
        create_file "config/initializers/open_themes.rb", initializer_contents
      end

      def ensure_stylesheet_imports
        adapter = options[:adapter]&.to_s

        if adapter == "tailwind"
          ensure_tailwind_theme_block
        else
          ensure_standard_imports
        end
      end

      private

      def ensure_tailwind_theme_block
        path = tailwind_entrypoint_path

        unless path
          say "⚠️  Tailwind entrypoint not found. Expected path:", :yellow
          say "  - app/assets/tailwind/application.css (Rails 8+)", :yellow
          say ""
          say "Theme CSS generated at app/assets/tailwind/open_themes.css", :green
          say "Please import it manually into your Tailwind entrypoint with:", :yellow
          say '  @import "./open_themes.css";', :yellow
          return
        end

        content = File.read(path)
        marker_begin = "/* OpenThemes:begin */"
        marker_end = "/* OpenThemes:end */"

        import_line = '@import "./open_themes.css";'
        block = "#{marker_begin}\n#{import_line}\n#{marker_end}"

        if content.include?(marker_begin)
          updated = content.sub(
            /#{Regexp.escape(marker_begin)}.*?#{Regexp.escape(marker_end)}/m,
            block
          )
          File.write(path, updated)
          say "Updated OpenThemes import in #{relative_path(path)}", :green
        else
          updated = if content.match?(/^\s*@import\s+["']tailwindcss["'];?\s*$/m)
                      content.sub(
                        /^(\s*@import\s+["']tailwindcss["'];?\s*)$/m,
                        "\\1\n\n#{block}\n"
                      )
                    else
                      "#{block}\n\n#{content}"
                    end

          File.write(path, updated)
          say "Added OpenThemes import to #{relative_path(path)}", :green
        end
      end

      def ensure_standard_imports
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
        return unless options[:components] && options[:adapter]&.to_s != "tailwind"

        say "Reference helpers: <%= ui_button \"Save\", variant: :primary %>"
      end

      def validate_adapter_option!
        adapter = options[:adapter]&.to_s
        return if adapter.nil? || adapter.empty?

        valid_adapters = %w[bootstrap tailwind]
        return if valid_adapters.include?(adapter)

        say "Unknown adapter: '#{adapter}'. Valid options: #{valid_adapters.join(", ")}", :red
        exit(1)
      end

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

      def tailwind_entrypoint_path
        path = File.join(destination_root, "app/assets/tailwind/application.css")
        File.exist?(path) ? path : nil
      end

      def relative_path(absolute_path)
        Pathname.new(absolute_path).relative_path_from(Pathname.new(destination_root)).to_s
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
