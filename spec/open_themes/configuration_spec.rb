# frozen_string_literal: true

RSpec.describe OpenThemes::Configuration do
  around do |example|
    OpenThemes.reset_configuration!
    example.run
    OpenThemes.reset_configuration!
  end

  it "resolves the configured theme via OpenThemes.current" do
    OpenThemes.configure do |config|
      config.theme = :catppuccin
      config.variant = :mocha
    end

    expect(OpenThemes.current.slug).to eq("catppuccin-mocha")
  end

  it "raises when theme is missing" do
    expect { OpenThemes.current }.to raise_error(OpenThemes::Error, /not configured/)
  end
end
