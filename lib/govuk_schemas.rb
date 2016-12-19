require "govuk_schemas/version"
require "govuk_schemas/schema"
require "govuk_schemas/utils"
require "govuk_schemas/random_example"
require "govuk_schemas/example"
require "govuk_schemas/validator"

module GovukSchemas
  # @private
  CONTENT_SCHEMA_DIR = ENV["GOVUK_CONTENT_SCHEMAS_PATH"] || "../govuk-content-schemas"

  # @private
  class InvalidContentGenerated < Exception
  end
end
