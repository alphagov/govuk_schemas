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

  describe ".uri" do
    it "generates a url" do
      random_content_generator = GovukSchemas::RandomContentGenerator.new
      url = "http://example.com"
      base_path = "foo/bar"
      anchor = "#foo"

      allow(Faker::Internet).to receive(:url).with(path: base_path) { url }
      allow(random_content_generator).to receive(:base_path) { base_path }
      allow(random_content_generator).to receive(:anchor) { "#foo" }

      response = random_content_generator.uri

      expect(response).to eq("#{url}#{anchor}")
    end
  end

  describe ".govuk_subdomain_url" do
    it "generates a uri" do
      random_content_generator = GovukSchemas::RandomContentGenerator.new
      host = "http://foo.gov.uk"
      base_path = "foo/bar"
      url = "#{host}/#{base_path}"

      allow(Faker::Internet).to receive(:domain_name).with(subdomain: true, domain: "gov.uk") { host }
      allow(random_content_generator).to receive(:base_path) { base_path }
      allow(Faker::Internet).to receive(:url).with(host:, path: base_path) { url }

      response = random_content_generator.govuk_subdomain_url

      expect(response).to eq(url)
    end
  end
end
