# frozen_string_literal: true

RSpec.describe OpenThemes::Validator do
  let(:valid_data) do
    {
      "schema_version" => 1,
      "id" => "example",
      "name" => "Example",
      "appearance" => "dark",
      "meta" => {
        "license" => "MIT",
        "source" => "https://example.com",
        "attribution" => "Example"
      },
      "palette" => {
        "base" => "#111111",
        "surface" => "#222222",
        "text" => "#eeeeee",
        "subtle" => "#aaaaaa",
        "line" => "#333333",
        "accent" => "#abcdef",
        "ok" => "#00ff00",
        "warn" => "#ffff00",
        "bad" => "#ff0000",
        "note" => "#0000ff"
      },
      "tokens" => {
        "background" => "base",
        "surface" => "surface",
        "text" => "text",
        "muted" => "subtle",
        "border" => "line",
        "primary" => "accent",
        "success" => "ok",
        "warning" => "warn",
        "danger" => "bad",
        "info" => "note",
        "on_primary" => "base",
        "on_success" => "base",
        "on_warning" => "base",
        "on_danger" => "base",
        "on_info" => "base"
      }
    }
  end

  it "accepts a valid theme payload" do
    expect(described_class.validate!(valid_data)).to be(true)
  end

  it "rejects unknown token references" do
    data = valid_data.merge(
      "tokens" => valid_data["tokens"].merge("primary" => "missing")
    )

    expect { described_class.validate!(data) }
      .to raise_error(OpenThemes::Validator::Error, /tokens.primary/)
  end

  it "rejects invalid hex colors" do
    data = valid_data.merge(
      "palette" => valid_data["palette"].merge("base" => "red")
    )

    expect { described_class.validate!(data) }
      .to raise_error(OpenThemes::Validator::Error, /palette.base/)
  end
end
