require "spec_helper"

RSpec.describe GovukSchemas::RandomContentGenerator do
  describe ".random_identifier" do
    it "generates a string" do
      string = GovukSchemas::RandomContentGenerator.new.random_identifier(separator: "_")

      expect(string).to be_a(String)
    end
  end
end
