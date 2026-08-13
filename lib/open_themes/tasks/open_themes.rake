# frozen_string_literal: true

namespace :open_themes do
  desc "Regenerate OpenThemes CSS from config/initializers/open_themes.rb"
  task apply: :environment do
    config = OpenThemes.configuration
    if config.theme.nil? || config.theme.to_s.empty?
      abort "OpenThemes is not configured. Run: bin/rails generate open_themes:install THEME [VARIANT]"
    end

    theme = OpenThemes::Installer.apply!(root: Rails.root, config: config)
    puts "Applied #{theme.display_name} → app/assets/stylesheets/open_themes/theme.css"
  end
end
