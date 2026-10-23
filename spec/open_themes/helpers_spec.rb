# frozen_string_literal: true

RSpec.describe OpenThemes::Helpers do
  let(:helper) do
    view = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
    view.extend(OpenThemes::Helpers)
    view
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
      result = helper.class_names("a", { "b" => true, "c" => false }, "d")
      expect(result).to eq("a b d")
    end

    it "class_names with array works" do
      result = helper.class_names(%w[a b], "c")
      expect(result).to eq("a b c")
    end

    it "class_names with nil values works" do
      result = helper.class_names("a", nil, "b", false, "c")
      expect(result).to eq("a b c")
    end

    it "ui_button still works correctly with Rails class_names available" do
      html = helper.ui_button("Test", variant: :primary, class: "custom")
      expect(html).to include("ot-btn ot-btn--primary custom")
    end

    it "ui_card still works correctly with Rails class_names available" do
      html = helper.ui_card(class: "extra") { "content" }
      expect(html).to include("ot-card extra")
    end
  end
end
