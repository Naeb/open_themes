# frozen_string_literal: true

require "tmpdir"
require "fileutils"

RSpec.describe OpenThemes::Installer do
  around do |example|
    OpenThemes.reset_configuration!
    example.run
    OpenThemes.reset_configuration!
  end

  it "writes a stable theme.css entrypoint" do
    Dir.mktmpdir do |dir|
      OpenThemes.configure do |config|
        config.theme = :nord
        config.foundation = true
        config.components = false
        config.adapter = nil
      end

      theme = described_class.apply!(root: dir)
      css = File.read(File.join(dir, "app/assets/stylesheets/open_themes/theme.css"))

      expect(theme.id).to eq("nord")
      expect(css).to include("--ot-primary:")
      expect(File).to exist(File.join(dir, "app/assets/stylesheets/open_themes/foundation.css"))
      expect(File).not_to exist(File.join(dir, "app/assets/stylesheets/open_themes/components.css"))
    end
  end

  it "lists stable import lines" do
    OpenThemes.configure do |config|
      config.theme = :dracula
      config.foundation = true
      config.components = true
      config.adapter = :bootstrap
    end

    lines = described_class.new(root: ".", config: OpenThemes.configuration).import_lines

    expect(lines).to eq(
      [
        '@import "open_themes/theme.css";',
        '@import "open_themes/foundation.css";',
        '@import "open_themes/components.css";',
        '@import "open_themes/adapters/bootstrap.css";'
      ]
    )
  end

  it "generates tailwind output when adapter is tailwind" do
    Dir.mktmpdir do |dir|
      OpenThemes.configure do |config|
        config.theme = :catppuccin
        config.variant = :mocha
        config.foundation = false
        config.components = false
        config.adapter = :tailwind
      end

      theme = described_class.apply!(root: dir)
      tailwind_css_path = File.join(dir, "app/assets/tailwind/open_themes.css")

      expect(theme.id).to eq("catppuccin")
      expect(theme.variant).to eq("mocha")
      expect(File).to exist(tailwind_css_path)

      tailwind_css = File.read(tailwind_css_path)
      expect(tailwind_css).to include("@theme inline")
      expect(tailwind_css).to include("--color-primary: var(--ot-primary)")

      expect(File).not_to exist(File.join(dir, "app/assets/stylesheets/open_themes/theme.css"))
      expect(File).not_to exist(File.join(dir, "app/assets/stylesheets/open_themes/foundation.css"))
    end
  end

  it "falls back to default variant when requested variant does not exist" do
    Dir.mktmpdir do |dir|
      OpenThemes.configure do |config|
        config.theme = :nord
        config.variant = :nonexistent
        config.adapter = nil
      end

      expect do
        theme = described_class.apply!(root: dir)
        expect(theme.id).to eq("nord")
        expect(theme.variant).to be_nil
      end.to output(/Warning: Variant 'nonexistent' not found/).to_stderr
    end
  end
end
