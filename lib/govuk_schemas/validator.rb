module GovukSchemas
  class Validator
    def self.schema_path(schema_name)
      schema_type = GovukContentSchemaTestHelpers.configuration.schema_type
      File.join(Util.govuk_content_schemas_path, "/formats/#{schema_name}/#{schema_type}/schema.json").to_s
    end

    # schema_name should be a string, such as 'finder'
    # document should be a JSON string of the document to validate
    def initialize(schema_name, document)
      Util.check_govuk_content_schemas_path!
      @schema_path = GovukContentSchemaTestHelpers::Validator.schema_path(schema_name)
      if !File.exists?(@schema_path)
        raise ImproperlyConfiguredError, "Schema file not found: #{@schema_path}."
      end
      @document = document
    end

    def valid?
      errors.empty?
    end

    def errors
      @errors ||= JSON::Validator.fully_validate(@schema_path, @document)
    end
  end
end
