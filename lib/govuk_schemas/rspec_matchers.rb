module GovukSchemas
  module RSpecMatchers
    RSpec::Matchers.define :be_valid_against_schema do |schema_name|
      match do |item|
        schema = Schema.find(publisher_schema: schema_name)
        validator = JSON::Validator.fully_validate(schema, item)
        validator.empty?
      end

      failure_message do |actual|
        ValidationErrorMessage.new(schema_name, "schema", actual).message
      end
    end

    RSpec::Matchers.define :be_valid_against_links_schema do |schema_name|
      match do |item|
        schema = Schema.find(links_schema: schema_name)
        validator = JSON::Validator.fully_validate(schema, item)
        validator.empty?
      end

      failure_message do |actual|
        ValidationErrorMessage.new(schema_name, "links", actual).message
      end
    end
  end

  class ValidationErrorMessage
    attr_reader :schema_name, :type, :payload

    def initialize(schema_name, type, payload)
      @schema_name = schema_name
      @type = type
      @payload = payload
    end

    def message
      <<~doc
      expected the payload to be valid against the '#{schema_name}' schema:

      #{formatted_payload}

      Validation errors:
      #{errors}
      doc
    end

  private

    def errors
      schema = Schema.find(publisher_schema: schema_name)
      validator = JSON::Validator.fully_validate(schema, payload)
      validator.map { |message| "- " + humanized_error(message) }.join("\n")
    end

    def formatted_payload
      return payload if payload.is_a?(String)
      JSON.pretty_generate(payload)
    end

    def humanized_error(message)
      message.gsub("The property '#/'", "The item")
    end
  end
end
