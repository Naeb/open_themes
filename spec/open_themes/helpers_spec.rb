# frozen_string_literal: true

RSpec.describe OpenThemes::Helpers do
  let(:helper) do
    Class.new do
      include OpenThemes::Helpers

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
end
