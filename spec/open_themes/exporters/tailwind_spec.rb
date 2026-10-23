# frozen_string_literal: true

RSpec.describe OpenThemes::Exporters::Tailwind do
  let(:theme) { OpenThemes.find(:catppuccin, variant: :mocha) }
  let(:output) { described_class.export(theme) }

  it "exports a @theme block" do
    expect(output).to include("@theme {")
    expect(output).to include("}")
  end

  it "includes header comment with theme metadata" do
    expect(output).to include("OpenThemes — Catppuccin Mocha")
    expect(output).to include("Tailwind adapter")
  end

  it "defines CSS variables with --ot- prefix" do
    expect(output).to include("--ot-background:")
    expect(output).to include("--ot-primary:")
    expect(output).to include("--ot-text:")
  end

  it "maps semantic tokens to Tailwind color utilities" do
    expect(output).to include("--color-primary: var(--ot-primary)")
    expect(output).to include("--color-background: var(--ot-background)")
    expect(output).to include("--color-surface: var(--ot-surface)")
    expect(output).to include("--color-text: var(--ot-text)")
    expect(output).to include("--color-muted: var(--ot-muted)")
    expect(output).to include("--color-border: var(--ot-border)")
  end

  it "includes intent colors" do
    expect(output).to include("--color-success: var(--ot-success)")
    expect(output).to include("--color-warning: var(--ot-warning)")
    expect(output).to include("--color-danger: var(--ot-danger)")
    expect(output).to include("--color-info: var(--ot-info)")
  end

  it "includes on-colors for text on colored backgrounds" do
    expect(output).to include("--color-on-primary: var(--ot-on-primary)")
    expect(output).to include("--color-on-success: var(--ot-on-success)")
  end

  it "resolves palette references to hex values" do
    # Catppuccin Mocha primary is mauve (#cba6f7)
    expect(output).to include("--ot-primary: #cba6f7")
  end

  it "uses hyphens in CSS token names" do
    # on_primary becomes on-primary
    expect(output).to include("--ot-on-primary:")
    expect(output).not_to include("--ot-on_primary:")
  end
end
