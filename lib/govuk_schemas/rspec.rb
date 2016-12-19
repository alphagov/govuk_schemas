require 'rspec/expectations'

RSpec::Matchers.define :be_valid_against_schema do |schema_name|
  match do |payload|
    schema = GovukSchemas::Schema.find(publisher_schema: schema_name)
    validator = GovukSchemas::Validator.new(schema, payload)
    validator.valid?
  end

  failure_message do |payload|
    schema = GovukSchemas::Schema.find(publisher_schema: schema_name)
    validator = GovukSchemas::Validator.new(schema, payload)
    GovukSchemas::ValidationErrorMessage.new(schema_name, payload, validator.errors).message
  end
end

RSpec::Matchers.define :be_valid_against_links_schema do |schema_name|
  match do |payload|
    schema = GovukSchemas::Schema.find(links_schema: schema_name)
    validator = GovukSchemas::Validator.new(schema, payload)
    validator.valid?
  end

  failure_message do |payload|
    schema = GovukSchemas::Schema.find(links_schema: schema_name)
    validator = GovukSchemas::Validator.new(schema, payload)
    GovukSchemas::ValidationErrorMessage.new(schema_name, payload, validator.errors).message
  end
end

# @private
module GovukSchemas
  class ValidationErrorMessage
    attr_reader :schema_name, :payload, :errors

    def initialize(schema_name, payload, errors)
      @schema_name = schema_name
      @payload = payload
      @errors = errors
    end

    def message
      <<~HEREDOC
        expected the payload to be valid against the '#{schema_name}' schema:

        Validation errors:
        #{formatted_errors}

        #{formatted_payload}
      HEREDOC
    end

  private
    def formatted_errors
      errors.map { |message| "- " + humanized_error(message) }.join("\n")
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
