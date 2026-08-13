# frozen_string_literal: true

RSpec.describe OpenThemes::Exporters::Css do
  it "exports semantic tokens as CSS custom properties" do
    theme = OpenThemes.find(:catppuccin, variant: :mocha)
    css = described_class.export(theme)

    expect(css).to include("OpenThemes — Catppuccin Mocha")
    expect(css).to include("Source: https://github.com/catppuccin/palette")
    expect(css).to include(":root {")
    expect(css).to include("--ot-primary: #cba6f7;")
    expect(css).to include("--ot-background: #1e1e2e;")
    expect(css).to include("--ot-danger: #f38ba8;")
    expect(css).to include("--ot-on-primary: #1e1e2e;")
    expect(css).to include("--ot-muted: #a6adc8;")
    expect(css).to include("--ot-border: #313244;")
  end
end
