require "spec_helper"

RSpec.describe GovukSchemas do
  around :each do |example|
    # resets content schema directory before and after each test so that these tests do not affect other tests' state
    GovukSchemas.content_schema_dir = nil
    example.run
    GovukSchemas.content_schema_dir = nil
  end

  describe "GovukSchemas" do
    describe ".content_schema_dir" do
      it "can be manually set" do
        described_class.content_schema_dir = "/manually/set/path"
        expect(described_class.content_schema_dir).to eql("/manually/set/path")
      end

      it "can be set via the GOVUK_CONTENT_SCHEMAS_PATH env variable when no path has been manually set" do
        ClimateControl.modify GOVUK_CONTENT_SCHEMAS_PATH: "/env/var/path" do
          expect(described_class.content_schema_dir).to eql("/env/var/path")
        end
      end

      it "uses the manually set variable over an environment variable" do
        ClimateControl.modify GOVUK_CONTENT_SCHEMAS_PATH: "/env/var/path" do
          described_class.content_schema_dir = "/manually/set/path"
          expect(described_class.content_schema_dir).to eql("/manually/set/path")
        end
      end

      it "uses the default path if no manually configured or env variable path has been set" do
        ClimateControl.modify GOVUK_CONTENT_SCHEMAS_PATH: nil do
          expect(described_class.content_schema_dir).to eql("../publishing-api/content_schemas")
        end
      end
    end
  end
end
