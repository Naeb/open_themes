# frozen_string_literal: true

module OpenThemes
  module Helpers
    BUTTON_VARIANTS = %w[primary success warning danger info outline ghost].freeze
    BUTTON_SIZES = %w[sm md lg].freeze

    def ui_button(label = nil, variant: :primary, size: :md, **html_options, &)
      options = button_options(variant:, size:, **html_options)

      if block_given?
        content_tag(:button, options, &)
      else
        content_tag(:button, label, options)
      end
    end

    def ui_card(**html_options, &)
      classes = ot_merge_classes("ot-card", html_options.delete(:class))
      content_tag(:div, html_options.merge(class: classes), &)
    end

    private

    def button_options(variant:, size:, **html_options)
      variant = normalize_choice(variant, BUTTON_VARIANTS, fallback: "primary")
      size = normalize_choice(size, BUTTON_SIZES, fallback: "md")

      {
        type: html_options.delete(:type) || "button",
        class: ot_merge_classes(
          "ot-btn",
          "ot-btn--#{variant}",
          ("ot-btn--#{size}" unless size == "md"),
          html_options.delete(:class)
        )
      }.merge(html_options)
    end

    def normalize_choice(value, allowed, fallback:)
      choice = value.to_s
      allowed.include?(choice) ? choice : fallback
    end

    def ot_merge_classes(*values)
      values.flatten.compact.reject(&:empty?).join(" ")
    end
  end
end
