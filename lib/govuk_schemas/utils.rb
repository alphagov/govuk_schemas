module GovukSchemas
  # @private
  module Utils
    def self.parameterize(string)
      string.gsub(/[^a-z0-9\-_]+/i, "-")
    end
  end
end
