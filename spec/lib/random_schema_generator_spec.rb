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

    describe "the default strategy" do
      it "doesn't generate values for optional properties as standard" do
        schema = {
          "type" => "object",
          "properties" => {
            "optional_field" => {
              "type" => "string",
            },
          },
        }

        stub_out_randomness

        generator = GovukSchemas::RandomSchemaGenerator.new(schema:)

        expect(generator.payload).to eq({})
      end
    end

    describe "the one-of-everything strategy" do
      it "generates values for all optional properties" do
        schema = {
          "type" => "object",
          "properties" => {
            "optional_field" => {
              "type" => "string",
            },
          },
        }

        stub_out_randomness

        strategy = GovukSchemas::RandomSchemaGenerator::ONE_OF_EVERYTHING_STRATEGY
        generator = GovukSchemas::RandomSchemaGenerator.new(schema:, strategy:)

        expect(generator.payload).to include(
          "optional_field" => an_instance_of(String),
        )
      end

      it "generates one item in every array" do
        schema = {
          "type" => "object",
          "properties" => {
            "list_a" => {
              "type" => "array",
              "items" => { "type" => "string" },
              "minItems" => 0,
            },
            "list_b" => {
              "type" => "array",
              "items" => { "type" => "string" },
              "maxItems" => 0,
            },
            "list_c" => {
              "type" => "array",
              "items" => { "type" => "string" },
              "minItems" => 5,
            },
            "list_d" => {
              "type" => "array",
              "items" => { "type" => "string" },
              "minItems" => 5,
              "maxItems" => 5,
            },
          },
        }

        strategy = GovukSchemas::RandomSchemaGenerator::ONE_OF_EVERYTHING_STRATEGY
        generator = GovukSchemas::RandomSchemaGenerator.new(schema:, strategy:)

        expect(generator.payload).to include(
          "list_a" => [an_instance_of(String)],
          "list_b" => [an_instance_of(String)],
          "list_c" => [an_instance_of(String)],
          "list_d" => [an_instance_of(String)],
        )
      end
    end

    # For any given optional property, RandomSchemaGenerator uses
    # RandomContentGenerator#bool to decide, randomly, whether to generate
    # a value or not. (Therefore, if we're testing its behaviour in the case
    # of optional properties, we need to control this variable.)
    def stub_out_randomness
      content_generator = GovukSchemas::RandomContentGenerator.new
      allow(content_generator).to receive(:bool).and_return(false)
      allow(GovukSchemas::RandomContentGenerator).to receive(:new)
        .and_return(content_generator)
    end
  end
end
