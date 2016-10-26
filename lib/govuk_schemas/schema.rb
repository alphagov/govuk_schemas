module GovukSchemas
  class Schema
    # Find a schema by name
    #
    # @param schema_name [String] Name of the schema/format
    # @param schema_type [String] The type: frontend, publisher, notification or links
    def self.find(schema_name, schema_type:)
      schema_type = "publisher_v2" if schema_type == "publisher"
      file_path = "#{GovukSchemas::CONTENT_SCHEMA_DIR}/formats/#{schema_name}/#{schema_type}/schema.json"
      JSON.parse(File.read(file_path))
    end

    # Return all schemas in a hash, keyed by schema name
    #
    # @param schema_type [String] The type: frontend, publisher, notification or links
    def self.all(schema_type: '*')
      schema_type = "publisher_v2" if schema_type == "publisher"
      Dir.glob("#{GovukSchemas::CONTENT_SCHEMA_DIR}/formats/*/#{schema_type}/*.json").reduce({}) do |hash, file_path|
        hash[file_path] = JSON.parse(File.read(file_path))
        hash
      end
    end

    # Return a random schema of a certain type
    #
    # @param schema_type [String] The type: frontend, publisher, notification or links
    def self.random_schema(schema_type:)
      all(schema_type: schema_type).values.sample
    end
  end
end
