#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/open_themes"

# Test 1: Helpers não sobrescrevem class_names
puts "Test 1: Verificando que ot_merge_classes é privado..."
helper_instance = Class.new { include OpenThemes::Helpers }.new
if helper_instance.respond_to?(:ot_merge_classes, true) && !helper_instance.respond_to?(:ot_merge_classes)
  puts "✓ ot_merge_classes é privado (não sobrescreve class_names do Rails)"
else
  puts "✗ FALHOU: ot_merge_classes não está privado"
  exit 1
end

# Test 2: Exporter Tailwind funciona
puts "\nTest 2: Testando Tailwind exporter..."
theme = OpenThemes.find(:catppuccin, variant: :mocha)
output = OpenThemes::Exporters::Tailwind.export(theme)

checks = [
  ["Contém @theme block", output.include?("@theme {")],
  ["Contém tokens --ot-*", output.include?("--ot-primary:")],
  ["Contém mapeamentos Tailwind", output.include?("--color-primary: var(--ot-primary)")],
  ["Contém cor resolvida", output.include?("#cba6f7")],
  ["Usa hífens (não underscores)", output.include?("--ot-on-primary:") && !output.include?("--ot-on_primary:")],
]

checks.each do |name, result|
  puts result ? "✓ #{name}" : "✗ FALHOU: #{name}"
  exit 1 unless result
end

# Test 3: Installer gera tailwind.css quando adapter=tailwind
puts "\nTest 3: Testando Installer com adapter=tailwind..."
require "tmpdir"
Dir.mktmpdir do |dir|
  OpenThemes.configure do |config|
    config.theme = :nord
    config.adapter = :tailwind
    config.foundation = false
    config.components = false
  end
  
  OpenThemes::Installer.apply!(root: dir)
  
  tailwind_path = File.join(dir, "app/assets/stylesheets/open_themes/tailwind.css")
  theme_path = File.join(dir, "app/assets/stylesheets/open_themes/theme.css")
  
  if File.exist?(tailwind_path) && !File.exist?(theme_path)
    content = File.read(tailwind_path)
    if content.include?("@theme {") && content.include?("Nord")
      puts "✓ Installer gera tailwind.css corretamente"
    else
      puts "✗ FALHOU: tailwind.css não tem conteúdo esperado"
      exit 1
    end
  else
    puts "✗ FALHOU: arquivos incorretos (esperado: tailwind.css, não theme.css)"
    exit 1
  end
  
  OpenThemes.reset_configuration!
end

puts "\n✓ Todos os testes básicos passaram!"
