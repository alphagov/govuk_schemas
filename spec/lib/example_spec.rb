require "spec_helper"

RSpec.describe GovukSchemas::Example do
  describe '.find' do
    it 'works' do
      example_content_item = GovukSchemas::Example.find("detailed_guide")

      expect(example_content_item).to be_a(Hash)
    end
  end

  describe '.for_formats' do
    it 'works' do
      examples = GovukSchemas::Example.for_formats(%w[detailed_guide topic])

      types = examples.map { |example_content_item| example_content_item["schema_name"] }.uniq

      expect(types).to eql(%w[detailed_guide topic])
    end
  end
end
