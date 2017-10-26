require "govuk_schemas/random"
require "govuk_schemas/random_item_generator"
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
    # @param [Hash] schema A JSON schema.
    # @return [GovukSchemas::RandomExample]
    def initialize(schema:)
      @schema = schema
      @random_generator = RandomItemGenerator.new(schema: schema)
    end

    # Returns a new `GovukSchemas::RandomExample` object.
    #
    # For example:
    #
    #     generator = GovukSchemas::RandomExample.for_schema(frontend_schema: "detailed_guide")
    #     generator.payload
    #     # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @param schema_key_value [Hash]
    # @return [GovukSchemas::RandomExample]
    def self.for_schema(schema_key_value)
      schema = GovukSchemas::Schema.find(schema_key_value)
      GovukSchemas::RandomExample.new(schema: schema)
    end

    # Return a content item merged with a hash and with the excluded fields removed.
    # If the resulting content item isn't valid against the schema an error will be raised.
    #
    # Example:
    #
    #      random = GovukSchemas::RandomExample.for_schema("detailed_guide", schema_type: "frontend")
    #      random.customise_and_validate({base_path: "/foo"}, ["withdrawn_notice"])
    #      # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @param [Hash] hash The hash to merge the random content with
    # @param [Array] array The array containing fields to exclude
    # @return [Hash] A content item
    # @raise [GovukSchemas::InvalidContentGenerated]
    def customise_and_validate(user_defined_values = {}, fields_to_exclude = [])
      random_payload = @random_generator.payload
      item_merged_with_user_input = random_payload.merge(Utils.stringify_keys(user_defined_values))
      item_merged_with_user_input.reject! { |k| fields_to_exclude.include?(k) }
      errors = validation_errors_for(item_merged_with_user_input)
      if errors.any?

        errors_on_random_payload = validation_errors_for(random_payload)
        if errors_on_random_payload.any?
          # The original item was invalid when it was generated, so it's not
          # the users fault.
          raise InvalidContentGenerated, error_message(random_payload, errors)
        else
          # The random item was valid, but it was merged with something invalid.
          raise InvalidContentGenerated, error_message_custom(item_merged_with_user_input, user_defined_values, errors)
        end
      end

      item_merged_with_user_input
    end

    # Return a hash with a random content item
    #
    # Example:
    #
    #     GovukSchemas::RandomExample.for_schema("detailed_guide", schema_type: "frontend").payload
    #     # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @return [Hash] A content item
    # Support backwards compatibility
    alias :payload :customise_and_validate
    alias :merge_and_validate :customise_and_validate

  private

    def validation_errors_for(item)
      JSON::Validator.fully_validate(@schema, item, errors_as_objects: true)
    end

    def error_message(item, errors)
      <<err
An invalid content item was generated.

This probably means there's a bug in the generator that causes it to output
invalid values. Below you'll find the generated payload, the validation errors
and the schema that was used.

Validation errors:
--------------------------

#{JSON.pretty_generate(errors)}

Generated payload:
--------------------------

#{JSON.pretty_generate([item])}
err
    end

    def error_message_custom(item, custom_values, errors)
      error_messages = errors.map { |e| "- #{e[:message]}\n" }.join

      <<err
The content item you are trying to generate is invalid against the schema.

Validation errors:
--------------------------

#{error_messages}

Custom values provided:
--------------------------

#{JSON.pretty_generate(custom_values)}

Generated payload:
--------------------------

#{JSON.pretty_generate([item])}
err
    end
  end
end
