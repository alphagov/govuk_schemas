require 'spec_helper'

RSpec.describe GovukSchemas::RandomExample do
  describe '.for_schema' do
    it 'returns a random example for a schema' do
      example = GovukSchemas::RandomExample.for_schema(frontend_schema: "placeholder")

      expect(example).to be_a(GovukSchemas::RandomExample)
    end
  end

  describe '#payload' do
    GovukSchemas::Schema.all.each do |file_path, schema|
      it "generates valid content for schema #{file_path}" do
        # This will raise an informative error if an invalid schema is generated.
        GovukSchemas::RandomExample.new(schema: schema).payload
      end
    end
  end

  describe "#merge_and_validate" do
    it "returns the merged payload" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

      item = GovukSchemas::RandomExample.new(schema: schema).merge_and_validate(base_path: "/some-base-path")

      expect(item["base_path"]).to eql("/some-base-path")
    end

    it "raises if the resulting content item won't be valid" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

      expect {
        GovukSchemas::RandomExample.new(schema: schema).merge_and_validate(base_path: nil)
      }.to raise_error(GovukSchemas::InvalidContentGenerated)
    end
  end

  describe "#customise_and_validate" do
    it "removes user defined fields for exclusion" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "notification")

      random_example = GovukSchemas::RandomExample.new(schema: schema).payload
      # Ensure that the example definitely has the field that the method we are testing will remove.
      # If we did not add this manually there would only be a 50:50 chance that it would be added by the random generation. This would cause the test to pass by accident 50% of the time.
      example_with_field = random_example.merge("withdrawn_notice" => {})

      allow_any_instance_of(GovukSchemas::RandomItemGenerator)
        .to receive(:payload)
        .and_return(example_with_field)

      item = GovukSchemas::RandomExample.new(schema: schema).customise_and_validate({}, ["withdrawn_notice"])

      expect(item).not_to include("withdrawn_notice")
    end

    it "raises if the resulting content item won't be valid" do
      schema = GovukSchemas::Schema.random_schema(schema_type: "frontend")

      expect {
        GovukSchemas::RandomExample.new(schema: schema).customise_and_validate({}, ["base_path"])
      }.to raise_error(GovukSchemas::InvalidContentGenerated)
    end
  end
end
