module GovukSchemas
  class Validator
    attr_reader :schema_name, :type
    attr_accessor :payload

    def initialize(schema_name, type, payload)
      @schema_name = schema_name
      @type = type
      @payload = ensure_json(payload)
    end

    def valid?
      errors.empty?
    end

    def error_message
      <<~DOC
        expected the payload to be valid against the '#{schema_name}' schema:

        #{formatted_payload}

        Validation errors:
        #{errors}
      DOC
    end

  private

    def errors
      schema = Schema.find("#{type}_schema": schema_name)
      validator = JSON::Validator.fully_validate(schema, payload)
      validator.map { |message| "- #{humanized_error(message)}" }.join("\n")
    end

    def formatted_payload
      JSON.pretty_generate(JSON.parse(payload))
    end

    def humanized_error(message)
      message.gsub("The property '#/'", "The item")
             .gsub(/in schema [0-9a-f-]+/, "")
             .strip
    end

    def ensure_json(payload)
      return payload if payload.is_a?(String)

      payload.to_json
    end
  end
end
