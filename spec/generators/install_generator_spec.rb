# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "generators/open_themes/install/install_generator"

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

  describe "with --adapter tailwind" do
    it "generates open_themes.css in app/assets/tailwind with @theme inline" do
      create_tailwind_entrypoint
      run_generator(["catppuccin", "mocha", "--adapter", "tailwind"])

      output_path = File.join(destination_root, "app/assets/tailwind/open_themes.css")
      expect(File).to exist(output_path)

      content = File.read(output_path)
      expect(content).to include("@theme inline")
      expect(content).to include(":root {")
      expect(content).to include("--ot-primary:")
      expect(content).to include("--color-primary: var(--ot-primary)")
      expect(content).to include("Catppuccin Mocha")
    end

    it "updates entrypoint with managed import" do
      entrypoint = create_tailwind_entrypoint

      run_generator(["nord", "--adapter", "tailwind"])

      content = File.read(entrypoint)
      expect(content).to include("/* OpenThemes:begin */")
      expect(content).to include('@import "./open_themes.css";')
      expect(content).to include("/* OpenThemes:end */")
    end

    it "is idempotent - running twice does not duplicate" do
      entrypoint = create_tailwind_entrypoint

      run_generator(["catppuccin", "mocha", "--adapter", "tailwind"])
      first_content = File.read(entrypoint)

      run_generator(["catppuccin", "mocha", "--adapter", "tailwind", "--force"])
      second_content = File.read(entrypoint)

      expect(first_content).to eq(second_content)
      expect(first_content.scan("OpenThemes:begin").size).to eq(1)
    end

    it "updates managed block when changing themes" do
      create_tailwind_entrypoint

      run_generator(["catppuccin", "mocha", "--adapter", "tailwind"])
      mocha_css = read_file("app/assets/tailwind/open_themes.css")

      run_generator(["nord", "--adapter", "tailwind", "--force"])
      nord_css = read_file("app/assets/tailwind/open_themes.css")

      expect(mocha_css).to include("Catppuccin Mocha")
      expect(nord_css).to include("Nord")
      expect(nord_css).not_to include("Catppuccin")
    end

    it "inserts after @import 'tailwindcss' if present" do
      entrypoint = create_tailwind_entrypoint('@import "tailwindcss";')

      run_generator(["nord", "--adapter", "tailwind"])

      content = File.read(entrypoint)
      lines = content.lines.map(&:strip)

      tailwind_index = lines.index('@import "tailwindcss";')
      theme_begin_index = lines.index("/* OpenThemes:begin */")

      expect(theme_begin_index).to be > tailwind_index
    end

    it "warns when Tailwind entrypoint is not found" do
      output = capture_output do
        run_generator(["nord", "--adapter", "tailwind"])
      end

      expect(output).to include("Tailwind entrypoint not found")
      expect(output).to include("app/assets/tailwind/application.css")

      expect(File).to exist(File.join(destination_root, "app/assets/tailwind/open_themes.css"))
    end

    it "includes components when --components is true" do
      create_tailwind_entrypoint

      run_generator(["nord", "--adapter", "tailwind", "--components"])

      content = read_file("app/assets/tailwind/open_themes.css")
      expect(content).to include(".ot-btn {")
      expect(content).to include("@apply")
    end

    it "excludes components when --no-components" do
      create_tailwind_entrypoint

      run_generator(["nord", "--adapter", "tailwind", "--no-components"])

      content = read_file("app/assets/tailwind/open_themes.css")
      expect(content).not_to include(".ot-btn")
    end

    it "handles tailwind import with source() and prefix() args" do
      create_tailwind_entrypoint('@import "tailwindcss" source(none) prefix(tw-);')

      run_generator(["nord", "--adapter", "tailwind"])

      app_css = read_file("app/assets/tailwind/application.css")
      expect(app_css).to include('@import "tailwindcss" source(none) prefix(tw-);')
      expect(app_css).to include("/* OpenThemes:begin */")
      expect(app_css).to include('@import "./open_themes.css";')
      expect(app_css).not_to match(/\n\n\n/)
    end
  end

  describe "standard adapter behavior" do
    it "generates theme.css in app/assets/stylesheets for bootstrap adapter" do
      create_stylesheet("app/assets/stylesheets/application.css")

      run_generator(["nord", "--adapter", "bootstrap"])

      expect(File).to exist(File.join(destination_root, "app/assets/stylesheets/open_themes/theme.css"))
      content = read_file("app/assets/stylesheets/open_themes/theme.css")
      expect(content).to include(":root {")
      expect(content).to include("--ot-primary:")
    end

    it "adds imports to application.css for bootstrap adapter" do
      app_css = create_stylesheet("app/assets/stylesheets/application.css")

      run_generator(["nord", "--adapter", "bootstrap"])

      content = File.read(app_css)
      expect(content).to include('@import "open_themes/theme.css";')
      expect(content).to include('@import "open_themes/adapters/bootstrap.css";')
    end

    it "generates standard files when no adapter specified" do
      create_stylesheet("app/assets/stylesheets/application.css")

      run_generator(%w[catppuccin mocha])

      expect(File).to exist(File.join(destination_root, "app/assets/stylesheets/open_themes/theme.css"))
      content = read_file("app/assets/stylesheets/application.css")
      expect(content).to include('@import "open_themes/theme.css";')
    end

    it "does not touch Tailwind entrypoint when adapter is not tailwind" do
      tailwind_entrypoint = create_tailwind_entrypoint
      app_css = create_stylesheet("app/assets/stylesheets/application.css")

      run_generator(["nord"])

      tailwind_content = File.read(tailwind_entrypoint)
      expect(tailwind_content).not_to include("OpenThemes")

      app_css_content = File.read(app_css)
      expect(app_css_content).to include('@import "open_themes/theme.css";')
    end
  end

  describe "validation" do
    it "raises Thor::Error for invalid adapter" do
      expect do
        run_generator(["nord", "--adapter=invalid"])
      end.to raise_error(Thor::Error, /Unknown adapter/)
    end
  end

  describe "adapter persistence" do
    it "reads adapter from existing initializer when not passed" do
      create_tailwind_entrypoint

      # First install with tailwind adapter
      run_generator(["catppuccin", "mocha", "--adapter", "tailwind"])

      # Re-run without --adapter flag; should read from initializer
      run_generator(["nord", "--force"])

      # Should have generated tailwind CSS
      tailwind_css = read_file("app/assets/tailwind/open_themes.css")
      expect(tailwind_css).to include("@theme inline")
      expect(tailwind_css).to include("Nord")
    end

    it "reads adapter from string form in initializer" do
      create_tailwind_entrypoint

      # Create initializer directory and file with string adapter
      FileUtils.mkdir_p(File.join(destination_root, "config/initializers"))
      File.write(
        File.join(destination_root, "config/initializers/open_themes.rb"),
        'OpenThemes.configure { |c| c.adapter = "tailwind" }'
      )

      run_generator(["nord", "--force"])

      tailwind_css = read_file("app/assets/tailwind/open_themes.css")
      expect(tailwind_css).to include("@theme inline")
    end

    it "ignores commented adapter in initializer" do
      create_stylesheet("app/assets/stylesheets/application.css")

      # Create initializer directory and file with commented adapter
      FileUtils.mkdir_p(File.join(destination_root, "config/initializers"))
      File.write(
        File.join(destination_root, "config/initializers/open_themes.rb"),
        "OpenThemes.configure { |c| c.theme = :nord\n  # c.adapter = :tailwind }"
      )

      run_generator(["nord", "--force"])

      # Should generate standard mode (no adapter)
      expect(File).to exist(File.join(destination_root, "app/assets/stylesheets/open_themes/theme.css"))
      expect(File).not_to exist(File.join(destination_root, "app/assets/tailwind/open_themes.css"))
    end
  end

  private

  def run_generator(args, allow_exit: false)
    OpenThemes.reset_configuration!
    positional_args, options_hash = parse_generator_args(args)

    generator = OpenThemes::Generators::InstallGenerator.new(
      positional_args,
      options_hash,
      { destination_root: destination_root }
    )

    allow(generator).to receive(:say)

    if allow_exit
      generator.invoke_all
    else
      begin
        generator.invoke_all
      rescue SystemExit => e
        raise e unless e.success?
      end
    end
  end

  def parse_generator_args(args)
    positional_args = []
    options_hash = {}

    i = 0
    while i < args.size
      arg = args[i]
      if arg.start_with?("--")
        consumed = parse_option(arg, args, i, options_hash)
        i += consumed # Skip consumed args (1 for flag, 2 for key=value pairs)
      else
        positional_args << arg
        i += 1
      end
    end

    [positional_args, options_hash]
  end

  def parse_option(arg, args, index, options_hash)
    if arg.include?("=")
      key, value = arg[2..].split("=", 2)
      options_hash[key.tr("-", "_").to_sym] = value
      1  # Consumed 1 arg
    elsif arg.start_with?("--no-")
      key = arg[5..].tr("-", "_")
      options_hash[key.to_sym] = false
      1  # Consumed 1 arg
    elsif should_consume_next_arg?(arg, args, index)
      options_hash[arg[2..].tr("-", "_").to_sym] = args[index + 1]
      2  # Consumed 2 args (key + value)
    else
      options_hash[arg[2..].tr("-", "_").to_sym] = true
      1  # Consumed 1 arg
    end
  end

  def should_consume_next_arg?(arg, args, index)
    !arg.include?("=") &&
      !arg.start_with?("--no-") &&
      index + 1 < args.size &&
      !args[index + 1].start_with?("--")
  end

  def create_tailwind_entrypoint(initial_content = "")
    path = File.join(destination_root, "app/assets/tailwind/application.css")
    mkdir_p(File.dirname(path))
    File.write(path, initial_content)
    path
  end

  def create_stylesheet(relative_path)
    path = File.join(destination_root, relative_path)
    mkdir_p(File.dirname(path))
    File.write(path, "")
    path
  end

  def read_file(relative_path)
    File.read(File.join(destination_root, relative_path))
  end

  def capture_output
    output = []

    positional_args = ["nord"]
    options_hash = { adapter: "tailwind" }

    generator = OpenThemes::Generators::InstallGenerator.new(
      positional_args,
      options_hash,
      { destination_root: destination_root }
    )

    allow(generator).to receive(:say) do |message, _color|
      output << message
    end

    generator.invoke_all
    output.join("\n")
  end
end
