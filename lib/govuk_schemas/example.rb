module GovukSchemas
  class Example
    # Find all examples for a schema
    #
    # @param schema_name [String] like "detailed_guide", "policy" or "publication"
    # @return [Array] array of example content items
    def self.find_all(schema_name)
      Dir.glob("#{GovukSchemas::CONTENT_SCHEMA_DIR}/formats/#{schema_name}/frontend/examples/*.json").map do |filename|
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
      path = "/formats/#{schema_name}/frontend/examples/#{example_name}.json"
      json = File.read("#{GovukSchemas::CONTENT_SCHEMA_DIR}#{path}")
      JSON.parse(json)
    end
  end
end
