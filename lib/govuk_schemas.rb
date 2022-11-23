require "govuk_schemas/version"
require "govuk_schemas/schema"
require "govuk_schemas/random_example"
require "govuk_schemas/document_types"
require "govuk_schemas/example"

module GovukSchemas
  def self.content_schema_dir=(path_to_schemas)
    @content_schema_dir = path_to_schemas
  end

  def self.content_schema_dir
    @content_schema_dir ||= ENV.fetch("GOVUK_CONTENT_SCHEMAS_PATH", "../publishing-api/content_schemas")
  end

  # @private
  class InvalidContentGenerated < RuntimeError
  end
end
