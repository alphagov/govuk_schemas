module GovukSchemas
  class DocumentTypes
    # Return all of the document types on GOV.UK
    def self.valid_document_types
      @valid_document_types ||= begin
        filename = "#{GovukSchemas::CONTENT_SCHEMA_DIR}/allowed_document_types.yml"
        YAML.load_file(filename)
      end
    end
  end
end
