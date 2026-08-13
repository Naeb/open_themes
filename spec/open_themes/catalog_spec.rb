# frozen_string_literal: true

RSpec.describe OpenThemes::Catalog do
  describe ".all" do
    it "loads every packaged theme" do
      themes = described_class.all

      expect(themes).not_to be_empty
      expect(themes.map(&:id).uniq).to include(
        "catppuccin",
        "tokyo-night",
        "nord",
        "dracula",
        "gruvbox"
      )
    end
  end

  describe ".find" do
    it "finds a theme by id and variant" do
      theme = described_class.find(:catppuccin, variant: :mocha)

      expect(theme.slug).to eq("catppuccin-mocha")
    end

    it "finds a theme without a variant" do
      theme = described_class.find(:nord)

      expect(theme.id).to eq("nord")
      expect(theme.variant).to be_nil
    end

    it "raises when the theme is missing" do
      expect { described_class.find(:missing) }
        .to raise_error(OpenThemes::Catalog::NotFound, /missing/)
    end
  end
end
