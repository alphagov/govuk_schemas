require 'spec_helper'

RSpec.describe GovukSchemas::Schema do
  describe '.find' do
    it 'returns a schema by name' do
      schema = GovukSchemas::Schema.find("detailed_guide", schema_type: "frontend")

      expect(schema).to be_a(Hash)
    end
  end

  describe '.all' do
    it 'returns all GOV.UK schemas' do
      schemas = GovukSchemas::Schema.all

      expect(schemas).to be_a(Hash)
    end
  end
end
