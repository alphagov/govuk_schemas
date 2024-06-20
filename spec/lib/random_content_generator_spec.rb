require "spec_helper"

RSpec.describe GovukSchemas::RandomContentGenerator do
  describe ".random_identifier" do
    it "generates a string" do
      string = GovukSchemas::RandomContentGenerator.new.random_identifier(separator: "_")

      expect(string).to be_a(String)
    end
  end

  describe ".string_for_type" do
    it "generates an email address" do
      email = "foo@example.com"
      allow(Faker::Internet).to receive(:email) { email }

      response = GovukSchemas::RandomContentGenerator.new.string_for_type("email")

      expect(response).to eq(email)
    end
  end
end
