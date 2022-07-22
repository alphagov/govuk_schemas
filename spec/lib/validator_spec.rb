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

    it "handles the payload being passed as json" do
      example = GovukSchemas::RandomExample.for_schema(publisher_schema: "placeholder").to_json
      validator = described_class.new("placeholder", "publisher", example)

      expect(validator.valid?).to eq true
    end
  end

  describe "#error_message" do
    let(:start_of_error_message) do
      <<~DOC
        expected the payload to be valid against the 'placeholder' schema:

        {
          "obviously_invalid": true
        }

        Validation errors:
      DOC
    end

    it "constructs an error message based on the schema_name, payload and errors" do
      example = { obviously_invalid: true }
      validator = described_class.new("placeholder", "publisher", example)

      expect(validator.error_message).to include start_of_error_message
      expect(validator.error_message).to match(/- The item did not contain a required property of '([a-z_]+)'/i)
      expect(validator.error_message).to include('- The item contains additional properties ["obviously_invalid"] outside of the schema when none are allowed')
    end
  end
end
