# frozen_string_literal: true

RSpec.describe OpenThemes::Helpers do
  let(:helper) do
    Class.new do
      include OpenThemes::Helpers

      # Simula o helper class_names nativo do Rails (ActionView::Helpers::TagHelper)
      def class_names(*args)
        tokens = []
        args.each do |arg|
          case arg
          when Hash
            tokens += arg.select { |_k, v| v }.keys.map(&:to_s)
          when Array
            tokens += arg.map(&:to_s)
          else
            tokens << arg.to_s if arg
          end
        end
        tokens.flatten.compact.reject(&:empty?).join(" ")
      end

      def content_tag(name, content_or_options = nil, options = nil, &block)
        if block
          options = content_or_options || {}
          content = yield
        else
          content = content_or_options
          options ||= {}
        end

        attrs = options.map { |key, value| "#{key}=\"#{value}\"" }.join(" ")
        "<#{name} #{attrs}>#{content}</#{name}>"
      end
    end.new
  end

  it "renders a primary button with component classes" do
    html = helper.ui_button("Save", variant: :primary)

    expect(html).to include("class=\"ot-btn ot-btn--primary\"")
    expect(html).to include("type=\"button\"")
    expect(html).to include(">Save</button>")
  end

  it "supports sizes, variants and custom classes" do
    html = helper.ui_button("Delete", variant: :danger, size: :lg, class: "extra")

    expect(html).to include("ot-btn--danger")
    expect(html).to include("ot-btn--lg")
    expect(html).to include("extra")
  end

  it "renders a card wrapper" do
    html = helper.ui_card(class: "panel") { "content" }

    expect(html).to include("class=\"ot-card panel\"")
    expect(html).to include(">content</div>")
  end

  describe "Rails class_names compatibility" do
    it "does not override Rails native class_names helper" do
      # O helper nativo do Rails aceita hashes e filtra por valores truthy
      result = helper.class_names("a", { "b" => true, "c" => false }, "d")
      expect(result).to eq("a b d")
    end

    it "ui_button still works correctly after class_names is defined" do
      # Garante que os helpers da gem não dependem de sobrescrever class_names
      html = helper.ui_button("Test", variant: :primary, class: "custom")
      expect(html).to include("ot-btn ot-btn--primary custom")
    end

    it "ui_card still works correctly after class_names is defined" do
      # Garante que ui_card também não depende de sobrescrever class_names
      html = helper.ui_card(class: "extra") { "content" }
      expect(html).to include("ot-card extra")
    end
  end
end
