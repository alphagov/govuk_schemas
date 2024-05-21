require "spec_helper"

RSpec.describe GovukSchemas::RandomExample do
  describe ".for_schema" do
    it "returns a random example for a schema" do
      example = GovukSchemas::RandomExample.for_schema(frontend_schema: "generic")

      expect(example).to be_a(Hash)
    end

    it "can be customised" do
      example = GovukSchemas::RandomExample.for_schema(frontend_schema: "generic") do |hash|
        hash.merge("base_path" => "/some-base-path")
      end

      expect(example["base_path"]).to eql("/some-base-path")
    end
  end

  describe "#payload" do
    GovukSchemas::Schema.all.each do |file_path, schema|
      it "generates valid content for schema #{file_path}" do
        # This will raise an informative error if an invalid schema is generated.
        GovukSchemas::RandomExample.new(schema:).payload
      end
    end

    it "returns the same output if a seed is detected" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")
      first_payload = GovukSchemas::RandomExample.new(schema:, seed: 777).payload
      second_payload = GovukSchemas::RandomExample.new(schema:, seed: 777).payload
      expect(first_payload).to eql(second_payload)
    end

    it "raises an error if the generated schema is invalid" do
      generator = instance_double(GovukSchemas::RandomSchemaGenerator, payload: {})
      allow(GovukSchemas::RandomSchemaGenerator).to receive(:new).and_return(generator)

      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")
      expect { GovukSchemas::RandomExample.new(schema:).payload }
        .to raise_error(GovukSchemas::InvalidContentGenerated)
    end

    context "when the payload is customised" do
      it "returns the customised payload" do
        schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

        example = GovukSchemas::RandomExample.new(schema:).payload do |hash|
          hash.merge("base_path" => "/some-base-path")
        end

        expect(example["base_path"]).to eql("/some-base-path")
      end

      it "raises if the resulting content item won't be valid" do
        schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

        expect {
          GovukSchemas::RandomExample.new(schema:).payload do |hash|
            hash.merge("base_path" => nil)
          end
        }.to raise_error(GovukSchemas::InvalidContentGenerated, /The item was valid before being customised/)
      end

      it "raises if the non-customised content item was invalid" do
        generator = instance_double(GovukSchemas::RandomSchemaGenerator, payload: {})
        allow(GovukSchemas::RandomSchemaGenerator).to receive(:new).and_return(generator)

        schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")
        expect { GovukSchemas::RandomExample.new(schema:).payload { |h| h.merge("base_path" => "/test") } }
          .to raise_error(GovukSchemas::InvalidContentGenerated, /An invalid content item was generated/)
      end
    end
  end
end
