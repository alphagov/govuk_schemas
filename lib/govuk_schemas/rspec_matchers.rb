require "govuk_schemas/validator"

module GovukSchemas
  module RSpecMatchers
    %w[links frontend publisher notification].each do |schema_type|
      RSpec::Matchers.define "be_valid_against_#{schema_type}_schema".to_sym do |schema_name|
        match do |item|
          @validator = GovukSchemas::Validator.new(schema_name, schema_type, item)
          @validator.valid?
        end

        failure_message { @validator.error_message }
      end
    end
  end
end
