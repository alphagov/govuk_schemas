require "spec_helper"
require "govuk_schemas/validator"

RSpec.describe GovukSchemas::Validator do
  describe "#valid?" do
    it "detects an valid schema" do
      example = GovukSchemas::RandomExample.for_schema(publisher_schema: "placeholder")
      validator = described_class.new("placeholder", "publisher", example)

      expect(validator.valid?).to eq true
    end

    it "detects an invalid schema" do
      example = { obviously_invalid: true }
      validator = described_class.new("placeholder", "publisher", example)

      expect(validator.valid?).to eq false
    end
  end

  describe "#error_message" do
    let(:expected_error_message) do
      <<~DOC
        expected the payload to be valid against the 'placeholder' schema:

        {
          "obviously_invalid": true
        }

        Validation errors:
        - The item did not contain a required property of 'base_path' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item did not contain a required property of 'details' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item did not contain a required property of 'document_type' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item did not contain a required property of 'publishing_app' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item did not contain a required property of 'rendering_app' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item did not contain a required property of 'routes' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item did not contain a required property of 'schema_name' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item did not contain a required property of 'title' in schema a6ce2f04-e077-594f-ac8a-864075c96db8
        - The item contains additional properties ["obviously_invalid"] outside of the schema when none are allowed in schema a6ce2f04-e077-594f-ac8a-864075c96db8
      DOC
    end

    it "constructs an error message based on the schema_name, payload and errors" do
      example = { obviously_invalid: true }
      validator = described_class.new("placeholder", "publisher", example)

      expect(validator.error_message).to eq expected_error_message
    end
  end
end
