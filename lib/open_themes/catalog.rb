# frozen_string_literal: true

require "pathname"

module OpenThemes
  class Catalog
    class NotFound < OpenThemes::Error; end

    def self.themes_path
      Pathname.new(__dir__).join("..", "..", "themes").expand_path
    end

    def self.all(root: themes_path)
      new(root: root).all
    end

    def self.find(id, variant: nil, root: themes_path)
      new(root: root).find(id, variant: variant)
    end

    def initialize(root: self.class.themes_path)
      @root = Pathname.new(root)
    end

    def all
      paths.map { |path| Theme.load(path) }
    end

    def find(id, variant: nil)
      id = id.to_s
      variant = normalize_variant(variant)

      match = all.find { |theme| theme.id == id && theme.variant.to_s == variant.to_s }
      return match if match

      raise NotFound, "theme not found: #{variant ? "#{id}/#{variant}" : id}"
    end

    def normalize_variant(variant)
      value = variant&.to_s
      value.nil? || value.empty? ? nil : value
    end

    private

    def paths
      Dir.glob(@root.join("**", "*.yml")).map { |path| Pathname.new(path) }
    end
  end
end
