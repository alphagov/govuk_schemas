require "spec_helper"

RSpec.describe GovukSchemas::Schema do
  describe ".find" do
    it "returns a frontend schema by name" do
      expect(GovukSchemas::Schema.find(frontend_schema: "detailed_guide")).to be_a(Hash)
    end

    it "returns a links schema schema by name" do
      expect(GovukSchemas::Schema.find(links_schema: "detailed_guide")).to be_a(Hash)
    end

    it "returns a publisher schema schema by name" do
      expect(GovukSchemas::Schema.find(publisher_schema: "detailed_guide")).to be_a(Hash)
    end

    it "returns a notification schema schema by name" do
      expect(GovukSchemas::Schema.find(notification_schema: "detailed_guide")).to be_a(Hash)
    end
  end

  describe ".all" do
    subject { GovukSchemas::Schema.all }

    it "returns all GOV.UK schemas" do
      expect(subject).to be_a(Hash)
    end
  end

  describe ".schema_names" do
    it "returns all schema names" do
      schema_names = GovukSchemas::Schema.schema_names

      expect(schema_names).to be_a(Array)
      expect(schema_names.size > 10).to eql(true)
    end
  end
end
