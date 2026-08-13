# frozen_string_literal: true

module OpenThemes
  class Validator
    REQUIRED_TOKENS = %w[
      background
      surface
      text
      muted
      border
      primary
      success
      warning
      danger
      info
      on_primary
      on_success
      on_warning
      on_danger
      on_info
    ].freeze

    APPEARANCES = %w[dark light].freeze
    HEX_PATTERN = /\A#[0-9a-fA-F]{6}\z/
    SCHEMA_VERSION = 1

    class Error < OpenThemes::Error; end

    def self.validate!(data, path: nil)
      new(data, path: path).validate!
    end

    def initialize(data, path: nil)
      @data = data || {}
      @path = path
      @errors = []
    end

    def validate! # rubocop:disable Naming/PredicateMethod
      validate_schema_version
      validate_identity
      validate_appearance
      validate_meta
      validate_palette
      validate_tokens

      raise Error, format_errors if @errors.any?

      true
    end

    private

    def validate_schema_version
      version = @data["schema_version"]
      return add_error("schema_version is required") if version.nil?
      return if version == SCHEMA_VERSION

      add_error("schema_version must be #{SCHEMA_VERSION}, got #{version.inspect}")
    end

    def validate_identity
      add_error("id is required") if blank?(@data["id"])
      add_error("name is required") if blank?(@data["name"])

      return unless @data.key?("variant") && blank?(@data["variant"])

      add_error("variant must not be blank when present")
    end

    def validate_appearance
      appearance = @data["appearance"]
      return add_error("appearance is required") if blank?(appearance)
      return if APPEARANCES.include?(appearance)

      add_error("appearance must be one of #{APPEARANCES.join(", ")}, got #{appearance.inspect}")
    end

    def validate_meta
      meta = @data["meta"]
      return add_error("meta is required") unless meta.is_a?(Hash)

      %w[license source attribution].each do |key|
        add_error("meta.#{key} is required") if blank?(meta[key])
      end
    end

    def validate_palette
      palette = @data["palette"]
      return add_error("palette is required") unless palette.is_a?(Hash)
      return add_error("palette must not be empty") if palette.empty?

      palette.each do |name, hex|
        next if hex.is_a?(String) && HEX_PATTERN.match?(hex)

        add_error("palette.#{name} must be a #RRGGBB hex color, got #{hex.inspect}")
      end
    end

    def validate_tokens
      tokens = @data["tokens"]
      return add_error("tokens is required") unless tokens.is_a?(Hash)

      palette_keys = palette_key_names
      REQUIRED_TOKENS.each { |token| validate_token_reference(tokens, token, palette_keys) }
    end

    def palette_key_names
      palette = @data["palette"]
      palette.is_a?(Hash) ? palette.keys.map(&:to_s) : []
    end

    def validate_token_reference(tokens, token, palette_keys)
      ref = tokens[token]
      return add_error("tokens.#{token} is required") if blank?(ref)
      return if palette_keys.include?(ref.to_s)

      add_error("tokens.#{token} references unknown palette key #{ref.inspect}")
    end

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end

    def add_error(message)
      @errors << message
    end

    def format_errors
      prefix = @path ? "#{@path}: " : ""
      "#{prefix}#{@errors.join("; ")}"
    end
  end
end
