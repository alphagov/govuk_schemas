require "spec_helper"

RSpec.describe GovukSchemas::Random do
  describe ".random_identifier" do
    it "generates a string" do
      string = GovukSchemas::Random.random_identifier(separator: "_")

      expect(string).to be_a(String)
    end
  end
end
