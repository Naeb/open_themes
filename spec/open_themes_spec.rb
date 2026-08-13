# frozen_string_literal: true

RSpec.describe OpenThemes do
  it "has a version number" do
    expect(OpenThemes::VERSION).not_to be_nil
  end

  it "delegates find to the catalog" do
    theme = described_class.find(:dracula)

    expect(theme.name).to eq("Dracula")
    expect(theme.resolved["primary"]).to eq("#bd93f9")
  end
end
