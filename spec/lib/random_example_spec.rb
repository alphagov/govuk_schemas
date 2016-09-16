require 'spec_helper'

RSpec.describe GovukSchemas::RandomExample do
  ITERATIONS = ENV['ITERATIONS'] || 1

  describe '#payload' do
    GovukSchemas::Schema.all.each do |file_path, schema|
      # TODO: we're unable to handle the specialist document schemas.
      next if file_path.match("specialist_document")

      # TODO: we're unable to handle the message_queue schemas.
      next if file_path.match("message_queue")

      it "generates valid content for schema #{file_path}" do
        # This will raise an informative error if an invalid schema is generated.
        ITERATIONS.times do
          GovukSchemas::RandomExample.new(schema: schema).payload
        end
      end
    end
  end
end
