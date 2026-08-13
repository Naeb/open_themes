# frozen_string_literal: true

module OpenThemes
  class Railtie < ::Rails::Railtie
    generators do
      require_relative "../generators/open_themes/install/install_generator"
    end

    rake_tasks do
      load File.expand_path("tasks/open_themes.rake", __dir__)
    end

    initializer "open_themes.helpers" do
      ActiveSupport.on_load(:action_view) do
        include OpenThemes::Helpers
      end
    end
  end
end
