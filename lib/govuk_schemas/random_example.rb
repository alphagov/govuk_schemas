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
  # links](https://github.com/alphagov/publishing-api/blob/a8039d430e44c86c3f54a69569f07ad48a4fc912/content_schemas/formats/shared/definitions/frontend_links.jsonnet#L118-L121).
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
    # @param [Hash]         schema  A JSON schema.
    # @param [Integer, nil] seed    A random number seed for deterministic results
    # @return [GovukSchemas::RandomExample]
    def initialize(schema:, seed: nil)
      @schema = schema
      @random_generator = RandomSchemaGenerator.new(schema:, seed:)
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
    # @param [Integer] seed The seed for RandomSchemaGenerator's random functions
    # @param [Block] the base payload is passed inton the block, with the block result then becoming
    #   the new payload. The new payload is then validated. (optional)
    # @return [GovukSchemas::RandomExample]
    def self.for_schema(seed: nil, **schema_key_value, &block)
      schema = GovukSchemas::Schema.find(schema_key_value)
      GovukSchemas::RandomExample.new(schema:, seed:).payload(&block)
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
    def payload(&block)
      payload = @random_generator.payload

      return customise_payload(payload, &block) if block

      errors = validation_errors_for(payload)
      raise InvalidContentGenerated, error_message(payload, errors) if errors.any?

      payload
    end

  private

    def customise_payload(payload)
      # Use Marshal to create a deep dup of the payload so the original can be mutated
      original_payload = Marshal.load(Marshal.dump(payload))
      customised_payload = yield(payload)
      customised_errors = validation_errors_for(customised_payload)

      if customised_errors.any?
        # Check if the original payload had errors and report those over
        # any from customisation. This is not done prior to generating the
        # customised payload because validation is time expensive and we
        # want to avoid it if possible.
        original_errors = validation_errors_for(original_payload)
        errors = original_errors.any? ? original_errors : customised_errors
        payload = original_errors.any? ? original_payload : customised_payload
        message = error_message(payload, errors, customised: original_errors.empty?)

        raise InvalidContentGenerated, message
      end

      customised_payload
    end

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
