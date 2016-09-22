require 'spec_helper'

RSpec.describe GovukSchemas::RandomExample do
  ITERATIONS = ENV['ITERATIONS'] || 1

  describe '#payload' do
    GovukSchemas::Schema.all.each do |file_path, schema|
      # Specialist documents have complex schemas that are hard to generate
      # content for. Same for the new message queue schema.
      skipped = file_path.match("specialist_document") || file_path.match("message_queue")

      it "generates valid content for schema #{file_path}", skip: skipped do
        ITERATIONS.times do
          # This will raise an informative error if an invalid schema is generated.
          GovukSchemas::RandomExample.new(schema: schema).payload
        end
      end
    end
  end

  describe "#merge_and_validate" do
    it "returns the merged payload" do
      schema = GovukSchemas::Schema.random_schema

      item = GovukSchemas::RandomExample.new(schema: schema).merge_and_validate(base_path: "/some-base-path")

      expect(item["base_path"]).to eql("/some-base-path")
    end

    it "raises if the resulting content item won't be valid" do
      schema = GovukSchemas::Schema.random_schema

      expect {
        GovukSchemas::RandomExample.new(schema: schema).merge_and_validate(base_path: nil)
      }.to raise_error(GovukSchemas::InvalidContentGenerated)
    end
  end
end
