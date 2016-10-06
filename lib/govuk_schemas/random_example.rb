require "govuk_schemas/random"
require "govuk_schemas/random_item_generator"
require "json-schema"
require "json"

module GovukSchemas
  class RandomExample
    # Returns a new `GovukSchemas::RandomExample` object.
    #
    # For example:
    #
    #     schema = GovukSchemas::Schema.find("detailed_guide", schema_type: "frontend")
    #     GovukSchemas::RandomExample.new(schema).payload
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
    #     generator = GovukSchemas::RandomExample.for_schema("detailed_guide", schema_type: "frontend")
    #     generator.payload
    #     # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @return [GovukSchemas::RandomExample]
    def self.for_schema(schema_name, schema_type:)
      schema = GovukSchemas::Schema.find(schema_name, schema_type: schema_type)
      GovukSchemas::RandomExample.new(schema: schema)
    end

    # Return a hash with a random content item
    #
    # Example:
    #
    #     GovukSchemas::RandomExample.for_schema("detailed_guide", schema_type: "frontend").payload
    #     # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @return [Hash] A content item
    def payload
      item = @random_generator.payload
      errors = validation_errors_for(item)

      if errors.any?
        raise InvalidContentGenerated, error_message(item, errors)
      end

      item
    end

    # Return a content item merged with a hash. If the resulting content item
    # isn't valid against the schema an error will be raised.
    #
    # Example:
    #
    #      random = GovukSchemas::RandomExample.for_schema("detailed_guide", schema_type: "frontend")
    #      random.merge_and_validate(base_path: "/foo")
    #      # => {"base_path"=>"/e42dd28e", "title"=>"dolor est...", "publishing_app"=>"elit"...}
    #
    # @param [Hash] hash The hash to merge the random content with
    # @return [Hash] A content item
    # @raise [GovukSchemas::InvalidContentGenerated]
    def merge_and_validate(hash)
      item = payload.merge(Utils.stringify_keys(hash))
      errors = validation_errors_for(item)

      if errors.any?
        raise InvalidContentGenerated, error_message_custom(item, hash, errors)
      end

      item
    end

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

Schema:
--------------------------

#{JSON.pretty_generate(@schema)}
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
