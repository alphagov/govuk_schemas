require 'spec_helper'

RSpec.describe GovukSchemas::RandomExample do
  CONTENT_SCHEMA_DIR = ENV["CONTENT_SCHEMA_DIR"] || "../govuk-content-schemas"

  describe '#payload' do
    files = Dir.glob("#{CONTENT_SCHEMA_DIR}/dist/**/*.json")

    files.each do |file|
      # TODO: this gem is currently unable to handle the message queue schema.
      next if file.match("message_queue")

      # TODO: we're unable to handle the specialist document schemas.
      next if file.match("specialist_documents")

      it "generates valid content for schema #{file}" do
        schema = JSON.parse(File.read(file))

        # This will raise an informative error if an invalid schema is generated.
        GovukSchemas::RandomExample.new(schema: schema).payload
      end
    end
  end
end
