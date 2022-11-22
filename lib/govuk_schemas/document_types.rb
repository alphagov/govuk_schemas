module GovukSchemas
  class DocumentTypes
    # Return all of the document types on GOV.UK
    def self.valid_document_types
      @valid_document_types ||= begin
        filename = "#{GovukSchemas.content_schema_dir}/lib/govuk_content_schemas/allowed_document_types.yml"
        YAML.load_file(filename)
      end
    end
  end
end
