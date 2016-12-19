require 'spec_helper'
require 'govuk_schemas/rspec'

RSpec.describe "RSpec integration" do
  describe "#be_valid_against_schema" do
    it "correctly tests valid schemas" do
      schema = GovukSchemas::Schema.find(publisher_schema: "generic")

      item = GovukSchemas::RandomExample.new(schema: schema).payload
      item.delete("base_path")

      expect(item).to be_valid_against_schema("generic")
    end

    it "fails for invalid schemas" do
      schema = GovukSchemas::Schema.find(publisher_schema: "generic")

      item = GovukSchemas::RandomExample.new(schema: schema).payload
      item.delete("base_path")

      expect(item).not_to be_valid_against_schema("generic")
    end
  end

  describe "#be_valid_against_links_schema" do
    it "correctly tests valid schemas" do
      schema = GovukSchemas::Schema.find(links_schema: "generic")

      item = GovukSchemas::RandomExample.new(schema: schema).payload

      expect(item).to be_valid_against_links_schema("generic")
    end

    it "fails for invalid schemas" do
      schema = GovukSchemas::Schema.find(links_schema: "generic")

      item = GovukSchemas::RandomExample.new(schema: schema).payload
      item["some_field_that_is_not_allowed"] = true

      expect(item).not_to be_valid_against_links_schema("generic")
    end
  end
end
