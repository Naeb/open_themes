# frozen_string_literal: true

RSpec.describe OpenThemes::Theme do
  let(:mocha_path) { OpenThemes.themes_path.join("catppuccin", "mocha.yml") }

  describe ".load" do
    it "loads and validates a theme YAML file" do
      theme = described_class.load(mocha_path)

      expect(theme.id).to eq("catppuccin")
      expect(theme.variant).to eq("mocha")
      expect(theme.appearance).to eq("dark")
      expect(theme.display_name).to eq("Catppuccin Mocha")
      expect(theme.slug).to eq("catppuccin-mocha")
    end

    it "resolves semantic tokens to palette hex values" do
      theme = described_class.load(mocha_path)

      expect(theme.resolved).to include(
        "background" => "#1e1e2e",
        "surface" => "#181825",
        "text" => "#cdd6f4",
        "muted" => "#a6adc8",
        "border" => "#313244",
        "primary" => "#cba6f7",
        "success" => "#a6e3a1",
        "warning" => "#f9e2af",
        "danger" => "#f38ba8",
        "info" => "#89b4fa",
        "on_primary" => "#1e1e2e"
      )
    end
  end
end
