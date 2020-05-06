require "spec_helper"

RSpec.describe GovukSchemas::RandomItemGenerator do
  describe "#payload" do
    it "generates an object with a required property" do
      schema = {
        "type" => "object",
        "required" => %w[my_field],
        "properties" => {
          "my_field" => {
            "type" => "string",
          },
        },
      }

      generator = GovukSchemas::RandomItemGenerator.new(schema: schema)

      expect(generator.payload.keys).to include("my_field")
    end

    it "handles JSON-references" do
      schema = {
        "type" => "object",
        "required" => %w[my_field],
        "properties" => {
          "my_field" => {
            "$ref" => "#/definitions/my_definition",
          },
        },
        "definitions" => {
          "my_definition" => {
            "type" => "string",
          },
        },
      }

      generator = GovukSchemas::RandomItemGenerator.new(schema: schema)

      expect(generator.payload.keys).to include("my_field")
    end

    it "handles nested JSON-references" do
      schema = {
        "type" => "object",
        "required" => %w[my_field],
        "properties" => {
          "my_field" => {
            "$ref" => "#/definitions/some_top_level_thing/definitions/my_definition",
          },
        },
        "definitions" => {
          "some_top_level_thing" => {
            "definitions" => {
              "my_definition" => {
                "type" => "string",
              },
            },
          },
        },
      }

      generator = GovukSchemas::RandomItemGenerator.new(schema: schema)

      expect(generator.payload.keys).to include("my_field")
    end

    it "handles required properties in oneOf" do
      schema = {
        "type" => "object",
        "properties" => {
          "my_enum" => {
            "enum" => %w[a b],
          },
          "my_field" => {
            "type" => "string",
          },
        },
        "oneOf" => [
          {
            "properties" => {
              "my_enum" => {
                "enum" => %w[a],
              },
            },
            "required" => %w[my_field],
          },
        ],
      }

      generator = GovukSchemas::RandomItemGenerator.new(schema: schema)

      expect(generator.payload["my_enum"]).to eq("a")
      expect(generator.payload.keys).to include("my_field")
    end
  end
end
