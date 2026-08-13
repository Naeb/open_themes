# frozen_string_literal: true

module OpenThemes
  REQUIRED_TOKENS = Validator::REQUIRED_TOKENS

  module_function

  def themes_path
    Catalog.themes_path
  end

  def all
    Catalog.all
  end

  def find(id, variant: nil)
    Catalog.find(id, variant: variant)
  end
end
