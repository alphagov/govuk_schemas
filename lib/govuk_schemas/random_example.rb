require "govuk_schemas/random_schema_generator"
require "json-schema"
require "json"

module GovukSchemas
  # Generate random content based on a schema.
  #
  # ## Limitations
  #
  # - The gem doesn't support `patternProperties` yet. On GOV.UK we [use this in
  # the expanded frontend
  # links](https://github.com/alphagov/govuk-content-schemas/blob/bdd97d18c7a9318e66f332f0748a410fddab1141/formats/frontend_links_definition.json#L67-L71).
  # - It's complicated to generate random data for `oneOf` properties. According
  # to the JSON Schema spec a `oneOf` schema is only valid if the data is valid
  # against *only one* of the clauses. To do this properly, we'd have to make
  # sure that the data generated below doesn't validate against the other
  # schemas properties.
  class RandomExample
    # Returns a new `GovukSchemas::RandomExample` object.
    #
    # For example:
    #
    #     schema = GovukSchemas::Schema.find(frontend_schema: "detailed_guide")
    #     GovukSchemas::RandomExample.new(schema: schema).payload
    #
    # Example with seed (for consistent results):
    #
    #     schema = GovukSchemas::Schema.find(frontend_schema: "detailed_guide")
    #     GovukSchemas::RandomExample.new(schema: schema, seed: 777).payload
    #     GovukSchemas::RandomExample.new(schema: schema, seed: 777).payload # returns same as above
    #
    # @param [Hash] schema A JSON schema.
    # @return [GovukSchemas::RandomExample]
    def initialize(schema:, seed: nil)
      @schema = schema
      @random_generator = RandomSchemaGenerator.new(schema: schema, seed: seed)
    end

    # Returns a new `GovukSchemas::RandomExample` object.
    #
    # Example without block:
    #
    #      GovukSchemas::RandomExample.for_schema(frontend_schema: "detailed_guide")
    #      # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # Example with block:
    #
    #      GovukSchemas::RandomExample.for_schema(frontend_schema: "detailed_guide") do |payload|
    #        payload.merge('base_path' => "Test base path")
    #      end
    #      # => {"base_path"=>"Test base path", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @param schema_key_value [Hash]
    # @param [Block] the base payload is passed inton the block, with the block result then becoming
    #   the new payload. The new payload is then validated. (optional)
    # @return [GovukSchemas::RandomExample]
    # @param [Block] the base payload is passed inton the block, with the block result then becoming
    #   the new payload. The new payload is then validated. (optional)
    def self.for_schema(schema_key_value, &block)
      schema = GovukSchemas::Schema.find(schema_key_value)
      GovukSchemas::RandomExample.new(schema: schema).payload(&block)
    end

    # Return a content item merged with a hash and with the excluded fields removed.
    # If the resulting content item isn't valid against the schema an error will be raised.
    #
    # Example without block:
    #
    #      generator.payload
    #      # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # Example with block:
    #
    #      generator.payload do |payload|
    #        payload.merge('base_path' => "Test base path")
    #      end
    #      # => {"base_path"=>"Test base path", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @param [Block] the base payload is passed inton the block, with the block result then becoming
    #   the new payload. The new payload is then validated. (optional)
    # @return [Hash] A content item
    # @raise [GovukSchemas::InvalidContentGenerated]
    def payload
      payload = @random_generator.payload
      # ensure the base payload is valid
      errors = validation_errors_for(payload)
      raise InvalidContentGenerated, error_message(payload, errors) if errors.any?

      if block_given?
        payload = yield(payload)
        # check the payload again after customisation
        errors = validation_errors_for(payload)
        raise InvalidContentGenerated, error_message(payload, errors, customised: true) if errors.any?
      end

      payload
    end

  private

    def validation_errors_for(item)
      JSON::Validator.fully_validate(@schema, item, errors_as_objects: true)
    end

    def error_message(item, errors, customised: false)
      details = <<~ERR
        Generated payload:
        --------------------------

        #{JSON.pretty_generate([item])}

        Validation errors:
        --------------------------

        #{JSON.pretty_generate(errors)}
      ERR

      if customised
        <<~ERR
          The content item you are trying to generate is invalid against the schema.
          The item was valid before being customised.

          #{details}
        ERR
      else
        <<~ERR
          An invalid content item was generated.

          This probably means there's a bug in the generator that causes it to output
          invalid values. Below you'll find the generated payload, the validation errors
          and the schema that was used.

          #{details}
        ERR
      end
    end
  end
end
