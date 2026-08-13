# frozen_string_literal: true

require "psych"
require "pathname"

module OpenThemes
  class Theme
    attr_reader :path, :data

    def self.load(path)
      path = Pathname.new(path)
      data = Psych.safe_load_file(path, aliases: true, permitted_classes: [Symbol])
      data = deep_stringify_keys(data)
      Validator.validate!(data, path: path.to_s)
      new(data, path: path)
    end

    def self.deep_stringify_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested), result|
          result[key.to_s] = deep_stringify_keys(nested)
        end
      when Array
        value.map { |item| deep_stringify_keys(item) }
      else
        value
      end
    end
    private_class_method :deep_stringify_keys

    def initialize(data, path: nil)
      @data = data
      @path = path && Pathname.new(path)
    end

    def id
      @data["id"]
    end

    def variant
      @data["variant"]
    end

    def name
      @data["name"]
    end

    def variant_name
      @data["variant_name"]
    end

    def appearance
      @data["appearance"]
    end

    def meta
      @data.fetch("meta")
    end

    def palette
      @data.fetch("palette")
    end

    def tokens
      @data.fetch("tokens")
    end

    def display_name
      if variant_name
        "#{name} #{variant_name}"
      else
        name
      end
    end

    def resolved
      tokens.transform_values { |ref| palette.fetch(ref.to_s) }
    end

    def slug
      variant ? "#{id}-#{variant}" : id
    end
  end
end
