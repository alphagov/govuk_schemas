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
end
