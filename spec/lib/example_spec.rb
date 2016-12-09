require 'spec_helper'

RSpec.describe GovukSchemas::Example do
  describe '.find_all' do
    it "returns all the examples" do
      examples = GovukSchemas::Example.find_all("specialist_document")

      expect(examples).to be_a(Array)
      expect(examples.size > 10).to eql(true)
    end
  end

  describe '.find' do
    it "returns one example" do
      example_content_item = GovukSchemas::Example.find("specialist_document", example_name: "drug-safety-update")

      expect(example_content_item).to be_a(Hash)
    end
  end
end
