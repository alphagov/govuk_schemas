require "spec_helper"
require "govuk_schemas/assert_matchers"

RSpec.describe GovukSchemas::AssertMatchers do
  include GovukSchemas::AssertMatchers

  def assert(boolean, error_message); end

  %w[publisher links frontend notification].each do |schema_type|
    describe "#assert_valid_against_#{schema_type}_schema" do
      it "detects an valid schema" do
        example = GovukSchemas::RandomExample.for_schema("#{schema_type}_schema": "generic")
        validator = GovukSchemas::Validator.new("generic", schema_type, example)
        expect(self).to receive(:assert).with(true, validator.error_message)

        public_send("assert_valid_against_#{schema_type}_schema", example, "generic")
      end

      it "detects an invalid schema" do
        example = { obviously_invalid: true, second_invalid_attribute: true }
        validator = GovukSchemas::Validator.new("generic", schema_type, example)
        expect(self).to receive(:assert).with(false, validator.error_message)

        public_send("assert_valid_against_#{schema_type}_schema", example, "generic")
      end
    end
  end
end
