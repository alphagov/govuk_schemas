module GovukSchemas
  class Schema
    # TODO: add docs
    def self.find(schema_name, schema_type:)
      schema_type = "publisher_v2" if schema_type == "publisher"
      path = ENV['GOVUK_CONTENT_SCHEMAS_PATH'] || '../govuk-content-schemas'
      file_path = "#{path}/dist/formats/#{schema_name}/#{schema_type}/schema.json"
      schema = JSON.parse(File.read(file_path))
    end
  end
end
