require "spec_helper"

RSpec.describe GovukSchemas::RandomSchemaGenerator do
  describe ".new" do
    it "returns non-equivalent generators on subsequent calls" do
      schema = {
        "type" => "object",
        "required" => %w[my_field],
        "properties" => {
          "my_field" => {
            "type" => "string",
          },
        },
      }
      generator1 = GovukSchemas::RandomSchemaGenerator.new(schema:)
      generator2 = GovukSchemas::RandomSchemaGenerator.new(schema:)

      expect(generator1.payload).not_to eq(generator2.payload)
    end
  end

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

      generator = GovukSchemas::RandomSchemaGenerator.new(schema:)

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

      generator = GovukSchemas::RandomSchemaGenerator.new(schema:)

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

      generator = GovukSchemas::RandomSchemaGenerator.new(schema:)

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

      generator = GovukSchemas::RandomSchemaGenerator.new(schema:)

      expect(generator.payload["my_enum"]).to eq("a")
      expect(generator.payload.keys).to include("my_field")
    end

    describe "unique arrays" do
      it "handles arrays that require unique items" do
        schema = {
          "type" => "array",
          "items" => { "type" => "string" },
          "uniqueItems" => true,
          "minItems" => 5,
          "maxItems" => 5,
        }

        generator = GovukSchemas::RandomSchemaGenerator.new(schema:)

        # These stubs are to ensure determinism in the random array value
        # generation.
        allow(generator).to receive(:generate_value).and_call_original
        allow(generator)
          .to receive(:generate_value)
          .with({ "type" => "string" })
          .and_return(*%w[a a b b c c d d e e])

        expect(generator.payload).to match_array(%w[a b c d e])
      end

      it "raises an error for a situation where it can't generate a random array" do
        schema = {
          "type" => "array",
          "items" => { "enum" => %w[a b] },
          "uniqueItems" => true,
          "minItems" => 3,
          "maxItems" => 3,
        }

        generator = GovukSchemas::RandomSchemaGenerator.new(schema:)

        expect { generator.payload }
          .to raise_error "Failed to create a unique array item after 300 attempts"
      end
    end
  end
end
