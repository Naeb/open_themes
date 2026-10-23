# frozen_string_literal: true

RSpec.describe OpenThemes::Exporters::Tailwind do
  let(:theme) { OpenThemes.find(:catppuccin, variant: :mocha) }

  describe "without components" do
    let(:output) { described_class.export(theme, components: false) }

    it "exports with @theme inline block" do
      expect(output).to include("@theme inline {")
      expect(output).to include("}")
    end

    it "defines tokens in :root" do
      expect(output).to include(":root {")
      expect(output).to include("--ot-background:")
      expect(output).to include("--ot-primary:")
      expect(output).to include("--ot-text:")
    end

    it "includes header comment with theme metadata" do
      expect(output).to include("OpenThemes — Catppuccin Mocha")
      expect(output).to include("Tailwind v4 adapter")
    end

    it "maps semantic tokens to Tailwind color utilities in @theme inline" do
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

    it "resolves palette references to hex values in :root" do
      expect(output).to include("--ot-primary: #cba6f7")
    end

    it "uses hyphens in CSS token names" do
      expect(output).to include("--ot-on-primary:")
      expect(output).not_to include("--ot-on_primary:")
    end

    it "does not include components" do
      expect(output).not_to include(".ot-btn")
      expect(output).not_to include("@apply")
    end
  end

  describe "with components" do
    let(:output) { described_class.export(theme, components: true) }

    it "includes component styles with @apply" do
      expect(output).to include(".ot-btn {")
      expect(output).to include("@apply")
      expect(output).to include(".ot-btn--primary")
      expect(output).to include(".ot-card")
    end

    it "still includes theme tokens and mappings" do
      expect(output).to include(":root {")
      expect(output).to include("@theme inline {")
      expect(output).to include("--color-primary: var(--ot-primary)")
    end
  end
end
