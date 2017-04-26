require 'spec_helper'
require 'govuk_schemas/rspec_matchers'

RSpec.describe GovukSchemas::RSpecMatchers do
  include GovukSchemas::RSpecMatchers

  describe '#be_valid_against_schema' do
    it 'detects an valid schema' do
      example = GovukSchemas::RandomExample.for_schema(publisher_schema: "placeholder").payload

      expect(example).to be_valid_against_schema("placeholder")
    end

    it 'detects an invalid schema' do
      example = { obviously_invalid: true }

      expect(example).to_not be_valid_against_schema("placeholder")
    end
  end

  describe '#be_valid_against_links_schema' do
    it 'detects an valid schema for links' do
      example = GovukSchemas::RandomExample.for_schema(links_schema: "placeholder").payload

      expect(example).to be_valid_against_links_schema("placeholder")
    end

    it 'detects an invalid schema for links' do
      example = { obviously_invalid: true }

      expect(example).to_not be_valid_against_links_schema("placeholder")
    end
  end
end
