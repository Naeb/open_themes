# frozen_string_literal: true

RSpec.describe "packaged themes" do
  it "validates and loads every theme YAML" do
    paths = Dir.glob(OpenThemes.themes_path.join("**", "*.yml"))
    expect(paths).not_to be_empty

    paths.each do |path|
      expect { OpenThemes::Theme.load(path) }.not_to raise_error
    end
  end

  it "exposes the required semantic tokens for every theme" do
    OpenThemes.all.each do |theme|
      expect(theme.resolved.keys).to match_array(OpenThemes::REQUIRED_TOKENS)
      theme.resolved.each_value do |hex|
        expect(hex).to match(/\A#[0-9a-fA-F]{6}\z/)
      end
    end
  end
end
