module GovukSchemas
  class Example
    # Find all examples for a schema
    #
    # @param schema_name [String] like "detailed_guide", "policy" or "publication"
    # @return [Array] array of example content items
    def self.find_all(schema_name)
      Dir.glob("#{examples_path(schema_name)}/*.json").map do |filename|
        json = File.read(filename)
        JSON.parse(json)
      end
    end

    # Find an example by name
    #
    # @param schema_name [String] like "detailed_guide", "policy" or "publication"
    # @param example_name [String] the name of the example JSON file
    # @return [Hash] the example content item
    def self.find(schema_name, example_name:)
      json = File.read("#{examples_path(schema_name)}/#{example_name}.json")
      JSON.parse(json)
    end

    # Examples are changing location in schemas, this allows this utility
    # to work with both locations
    #
    # @param schema_name [String] like "detailed_guide", "policy" or "publication"
    # @return [String] the path to use for examples
    def self.examples_path(schema_name)
      examples_dir = "#{GovukSchemas::CONTENT_SCHEMA_DIR}/examples"
      if Dir.exist?(examples_dir)
        "#{examples_dir}/#{schema_name}/frontend"
      else
        "#{GovukSchemas::CONTENT_SCHEMA_DIR}/formats/#{schema_name}/frontend/examples"
      end
    end
  end
end
