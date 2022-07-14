require "govuk_schemas/validator"

module GovukSchemas
  module AssertMatchers
    def assert_valid_against_publisher_schema(payload, schema_name)
      assert_valid_against_schema(payload, schema_name, "publisher")
    end

    def assert_valid_against_links_schema(payload, schema_name)
      assert_valid_against_schema(payload, schema_name, "links")
    end

    def assert_valid_against_frontend_schema(payload, schema_name)
      assert_valid_against_schema(payload, schema_name, "frontend")
    end

    def assert_valid_against_notification_schema(payload, schema_name)
      assert_valid_against_schema(payload, schema_name, "notification")
    end

  private

    def assert_valid_against_schema(payload, schema_name, schema_type)
      validator = GovukSchemas::Validator.new(schema_name, schema_type, payload)
      assert validator.valid?, validator.error_message
    end
  end
end
