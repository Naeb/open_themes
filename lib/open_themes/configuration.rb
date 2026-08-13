# frozen_string_literal: true

module OpenThemes
  class Configuration
    attr_accessor :theme, :variant, :foundation, :components, :adapter

    def initialize
      @theme = nil
      @variant = nil
      @foundation = true
      @components = true
      @adapter = nil
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def current
      config = configuration
      raise Error, "OpenThemes theme is not configured. Set config.theme in an initializer." if blank?(config.theme)

      find(config.theme, variant: config.variant)
    end

    def blank?(value)
      value.nil? || (value.respond_to?(:empty?) && value.empty?)
    end
  end
end
