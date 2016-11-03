module GovukSchemas
  class Schema
    # Find a schema by name
    #
    # @param schema [Hash] Type => Name of the schema/format:
    # Accepted arguments:
    # { links_schema: schema_name }
    # { frontend_schema: schema_name }
    # { publisher_schema: schema_name }
    # { notification_schema: schema_name }
    def self.find(schema)
      file_path = "#{GovukSchemas::CONTENT_SCHEMA_DIR}/dist/formats/#{type_location(schema)}"
      JSON.parse(File.read(file_path))
    end

    # Find a schema type location by name
    #
    # @param schema [Hash] Type => Name of the schema/format:
    # Accepted arguments:
    # { links_schema: schema_name }
    # { frontend_schema: schema_name }
    # { publisher_schema: schema_name }
    # { notification_schema: schema_name }
    def self.type_location(schema)
      type, schema_name = schema.to_a.flatten
      {
        links_schema: "#{schema_name}/publisher_v2/links.json",
        frontend_schema: "#{schema_name}/frontend/schema.json",
        publisher_schema: "#{schema_name}/publisher_v2/schema.json",
        notification_schema: "#{schema_name}/notification/schema.json",
      }[type]
    end

    # Return all schemas in a hash, keyed by schema name
    #
    # @param schema_type [String] The type: frontend, publisher, notification or links
    def self.all(schema_type: '*')
      schema_type = "publisher_v2" if schema_type == "publisher"
      Dir.glob("#{GovukSchemas::CONTENT_SCHEMA_DIR}/dist/formats/*/#{schema_type}/*.json").reduce({}) do |hash, file_path|
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
