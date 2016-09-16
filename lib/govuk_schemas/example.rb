module GovukSchemas
  # Use the custom examples from the govuk-content-schemas project.
  class Example

    # Fetch an individual example.
    #
    #     GovukSchemas::Example.find("detailed_guide")
    #
    #     GovukSchemas::Example.find("detailed_guide", "a_particular_guide")
    #
    # @param schema_name [String] Name of the schema/format
    # @param example_name [String] (optional) Name of the example
    def self.find(schema_name, example_name = schema_name)
      file_path = "#{GovukSchemas::CONTENT_SCHEMA_DIR}/formats/#{schema_name}/frontend/examples/#{example_name}.json"
      JSON.parse(File.read(file_path))
    end

    # Fetch all examples for schema names
    #
    # @param [Array] schema names
    #
    #     GovukSchemas::Example.for_formats("detailed_guide")
    #
    #     GovukSchemas::Example.for_formats("detailed_guide", "topic")
    #
    def self.for_formats(*the_formats)
      the_formats.flatten!

      Dir.glob("#{GovukSchemas::CONTENT_SCHEMA_DIR}/formats/*/frontend/examples/*.json").map do |file_path|
        schema_name = file_path.split('/')[3]
        next unless the_formats.include?(schema_name)
        JSON.parse(File.read(file_path))
      end.compact
    end
  end
end
