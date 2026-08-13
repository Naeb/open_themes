# frozen_string_literal: true

require_relative "lib/open_themes/version"

Gem::Specification.new do |spec|
  spec.name = "open_themes"
  spec.version = OpenThemes::VERSION
  spec.authors = ["Guilherme Berlintes"]
  spec.email = ["guilherme.berlintes@outlook.com"]

  spec.summary = "Community visual themes normalized into semantic design tokens."
  spec.description = <<~DESC.chomp
    OpenThemes collects community color palettes, maps them to shared semantic
    tokens, and exports CSS variables for apps (including Rails).
  DESC
  spec.homepage = "https://github.com/berlintes/open_themes"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/berlintes/open_themes"
  spec.metadata["changelog_uri"] = "https://github.com/berlintes/open_themes/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
