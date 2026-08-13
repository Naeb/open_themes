# frozen_string_literal: true

RSpec.describe OpenThemes::Assets do
  it "exposes foundation structural tokens" do
    css = described_class.foundation_css

    expect(css).to include("--ot-space-4")
    expect(css).to include("--ot-radius-md")
    expect(css).to include("--ot-focus-ring")
    expect(css).to include(".ot-container")
  end

  it "exposes the optional reference components stylesheet" do
    css = described_class.components_css

    expect(css).to include(".ot-btn")
    expect(css).to include(".ot-btn--primary")
    expect(css).to include("var(--ot-on-primary)")
    expect(css).to include("var(--ot-radius-md)")
    expect(css).to include(".ot-card")
  end

  it "exposes framework adapters" do
    css = described_class.adapter_css(:bootstrap)

    expect(css).to include("--bs-primary: var(--ot-primary);")
    expect(css).to include("--bs-body-bg: var(--ot-background);")
  end

  it "rejects unknown adapters" do
    expect { described_class.adapter_css(:nope) }
      .to raise_error(ArgumentError, /unknown adapter/)
  end
end
