require 'spec_helper'

RSpec.describe GovukSchemas::RandomItemGenerator do
  describe '#payload' do
    it 'generate an object with a required property' do
      schema = {
        "type" => "object",
        "required" => ["my_field"],
        "properties" => {
          "my_field" => {
            "type" => "string"
          }
        }
      }

      generator = GovukSchemas::RandomItemGenerator.new(schema: schema)

      expect(generator.payload.keys).to include('my_field')
    end
  end
end
