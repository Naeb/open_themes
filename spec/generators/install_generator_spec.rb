# frozen_string_literal: true

require "rails/generators/test_case"
require "tmpdir"
require "fileutils"

RSpec.describe OpenThemes::Generators::InstallGenerator do
  include FileUtils

  around do |example|
    OpenThemes.reset_configuration!
    
    Dir.mktmpdir do |dir|
      @destination_root = dir
      example.run
    end
    
    OpenThemes.reset_configuration!
  end

  let(:destination_root) { @destination_root }

  describe "with --adapter=tailwind" do
    it "generates tailwind.css with @theme block" do
      create_tailwind_entrypoint("app/assets/tailwind/application.css")
      
      run_generator(["catppuccin", "mocha", "--adapter=tailwind"])
      
      tailwind_css = read_file("app/assets/stylesheets/open_themes/tailwind.css")
      expect(tailwind_css).to include("@theme {")
      expect(tailwind_css).to include("--color-primary: var(--ot-primary)")
      expect(tailwind_css).to include("Catppuccin Mocha")
    end

    it "detects Rails 8 Tailwind entrypoint" do
      entrypoint = create_tailwind_entrypoint("app/assets/tailwind/application.css")
      
      run_generator(["nord", "--adapter=tailwind"])
      
      content = File.read(entrypoint)
      expect(content).to include("/* OpenThemes:tailwind:begin */")
      expect(content).to include('@import "../stylesheets/open_themes/tailwind.css";')
      expect(content).to include("/* OpenThemes:tailwind:end */")
    end

    it "detects Rails 7 Tailwind entrypoint" do
      entrypoint = create_tailwind_entrypoint("app/assets/stylesheets/application.tailwind.css")
      
      run_generator(["nord", "--adapter=tailwind"])
      
      content = File.read(entrypoint)
      expect(content).to include("/* OpenThemes:tailwind:begin */")
      expect(content).to include('@import "open_themes/tailwind.css";')
      expect(content).to include("/* OpenThemes:tailwind:end */")
    end

    it "is idempotent - running twice does not duplicate" do
      entrypoint = create_tailwind_entrypoint("app/assets/tailwind/application.css")
      
      run_generator(["catppuccin", "mocha", "--adapter=tailwind"])
      first_content = File.read(entrypoint)
      
      run_generator(["catppuccin", "mocha", "--adapter=tailwind", "--force"])
      second_content = File.read(entrypoint)
      
      expect(first_content).to eq(second_content)
      expect(first_content.scan(/OpenThemes:tailwind:begin/).size).to eq(1)
    end

    it "updates block when changing themes" do
      entrypoint = create_tailwind_entrypoint("app/assets/tailwind/application.css")
      
      run_generator(["catppuccin", "mocha", "--adapter=tailwind"])
      mocha_css = read_file("app/assets/stylesheets/open_themes/tailwind.css")
      
      run_generator(["nord", "--adapter=tailwind", "--force"])
      nord_css = read_file("app/assets/stylesheets/open_themes/tailwind.css")
      
      expect(mocha_css).to include("Catppuccin Mocha")
      expect(nord_css).to include("Nord")
      expect(nord_css).not_to include("Catppuccin")
      
      # Entrypoint should still have only one block
      content = File.read(entrypoint)
      expect(content.scan(/OpenThemes:tailwind:begin/).size).to eq(1)
    end

    it "inserts after @import 'tailwindcss' if present" do
      entrypoint = create_tailwind_entrypoint(
        "app/assets/tailwind/application.css",
        '@import "tailwindcss";'
      )
      
      run_generator(["nord", "--adapter=tailwind"])
      
      content = File.read(entrypoint)
      lines = content.lines.map(&:strip)
      
      import_index = lines.index('@import "tailwindcss";')
      theme_begin_index = lines.index("/* OpenThemes:tailwind:begin */")
      
      expect(theme_begin_index).to be > import_index
    end

    it "warns when Tailwind entrypoint is not found" do
      # Don't create a Tailwind entrypoint
      
      output = capture_generator_output do
        run_generator(["nord", "--adapter=tailwind"])
      end
      
      expect(output).to include("Tailwind entrypoint not found")
      expect(output).to include("app/assets/tailwind/application.css")
      expect(output).to include("app/assets/stylesheets/application.tailwind.css")
      
      # Should still generate the CSS file
      expect(File).to exist(File.join(destination_root, "app/assets/stylesheets/open_themes/tailwind.css"))
    end

    it "validates adapter option" do
      create_tailwind_entrypoint("app/assets/tailwind/application.css")
      
      expect {
        run_generator(["nord", "--adapter=invalid"])
      }.to raise_error(/Unknown adapter: 'invalid'/)
    end
  end

  describe "standard adapter behavior" do
    it "uses standard imports for bootstrap adapter" do
      create_stylesheet("app/assets/stylesheets/application.css")
      
      run_generator(["nord", "--adapter=bootstrap"])
      
      css = read_file("app/assets/stylesheets/application.css")
      expect(css).to include('@import "open_themes/theme.css";')
      expect(css).to include('@import "open_themes/adapters/bootstrap.css";')
      expect(css).not_to include("OpenThemes:tailwind:begin")
    end

    it "uses standard imports when no adapter specified" do
      create_stylesheet("app/assets/stylesheets/application.css")
      
      run_generator(["catppuccin", "mocha"])
      
      css = read_file("app/assets/stylesheets/application.css")
      expect(css).to include('@import "open_themes/theme.css";')
      expect(File).to exist(File.join(destination_root, "app/assets/stylesheets/open_themes/theme.css"))
    end
  end

  private

  def run_generator(args)
    generator_class = OpenThemes::Generators::InstallGenerator
    generator = generator_class.new(args, {}, { destination_root: destination_root })
    
    # Suppress output during tests
    allow(generator).to receive(:say)
    
    generator.invoke_all
  end

  def create_tailwind_entrypoint(path, initial_content = "")
    full_path = File.join(destination_root, path)
    mkdir_p(File.dirname(full_path))
    File.write(full_path, initial_content)
    full_path
  end

  def create_stylesheet(path)
    full_path = File.join(destination_root, path)
    mkdir_p(File.dirname(full_path))
    File.write(full_path, "")
    full_path
  end

  def read_file(relative_path)
    File.read(File.join(destination_root, relative_path))
  end

  def capture_generator_output
    output = StringIO.new
    generator_class = OpenThemes::Generators::InstallGenerator
    generator = generator_class.new(["nord", "--adapter=tailwind"], {}, { destination_root: destination_root })
    
    # Capture say calls
    allow(generator).to receive(:say) do |message, color|
      output.puts(message)
    end
    
    generator.invoke_all
    output.string
  end
end
