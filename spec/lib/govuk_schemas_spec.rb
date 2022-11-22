require "spec_helper"

RSpec.describe GovukSchemas do
  describe ".content_schema_dir" do
    around do |example|
      # reset content_schema_dir before and after so these tests don't leave side
      # effects
      described_class.content_schema_dir = nil
      example.run
      described_class.content_schema_dir = nil
    end

    it "defaults to '../govuk-content-schemas'" do
      ClimateControl.modify GOVUK_CONTENT_SCHEMAS_PATH: nil do
        expect(described_class.content_schema_dir).to eq("../govuk-content-schemas")
      end
    end

    it "can be configured by the GOVUK_CONTENT_SCHEMAS_PATH env var" do
      ClimateControl.modify GOVUK_CONTENT_SCHEMAS_PATH: "/path/to/schemas" do
        expect(described_class.content_schema_dir).to eq("/path/to/schemas")
      end
    end

    it "can be configured by manual initialisation" do
      described_class.content_schema_dir = "/another/path/schemas"
      expect(described_class.content_schema_dir).to eq("/another/path/schemas")
    end

    it "lets manual initialisation takes precedence over an env var" do
      described_class.content_schema_dir = "/another/path/schemas"
      ClimateControl.modify GOVUK_CONTENT_SCHEMAS_PATH: "/path/to/schemas" do
        expect(described_class.content_schema_dir).to eq("/another/path/schemas")
      end
    end
  end
end
