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

    it "can customise the payload" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

      example = GovukSchemas::RandomExample.new(schema:).payload do |hash|
        hash.merge("base_path" => "/some-base-path")
      end

      expect(example["base_path"]).to eql("/some-base-path")
    end

    it "failes when attempting to edit the hash in place" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

      expect {
        GovukSchemas::RandomExample.new(schema:).payload do |hash|
          hash["base_path"] = "/some-base-path"
        end
      }.to raise_error(GovukSchemas::InvalidContentGenerated)
    end

    it "raises if the resulting content item won't be valid" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

      expect {
        GovukSchemas::RandomExample.new(schema:).payload do |hash|
          hash.merge("base_path" => nil)
        end
      }.to raise_error(GovukSchemas::InvalidContentGenerated)
    end
  end
end
