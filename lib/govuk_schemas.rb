require "govuk_schemas/version"
require "govuk_schemas/schema"
require "govuk_schemas/utils"
require "govuk_schemas/random_example"
require "govuk_schemas/document_types"
require "govuk_schemas/example"

module GovukSchemas
  # @private
  CONTENT_SCHEMA_DIR = ENV["GOVUK_CONTENT_SCHEMAS_PATH"] || "../govuk-content-schemas"

  # @private
  class InvalidContentGenerated < RuntimeError
  end
end
