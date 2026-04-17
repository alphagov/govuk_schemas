require "spec_helper"

RSpec.describe GovukSchemas::RandomContentGenerator do
  describe ".random_identifier" do
    it "generates a string" do
      string = GovukSchemas::RandomContentGenerator.new.random_identifier

      expect(string).to be_a(String)
      expect(string).to match(/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
    end

    it "can accept a different separator" do
      string = GovukSchemas::RandomContentGenerator.new.random_identifier(separator: "$")

      expect(string).to match(/^[a-z0-9]+(?:\$[a-z0-9]+)*$/)
    end
  end

  describe ".string_for_type" do
    it "generates an email address" do
      response = GovukSchemas::RandomContentGenerator.new.string_for_type("email")

      expect(response).to match(URI::MailTo::EMAIL_REGEXP)
    end

    it "raises an error if the type is not present" do
      expect {
        GovukSchemas::RandomContentGenerator.new.string_for_type("duration")
      }.to raise_error(/Unsupported JSON schema type `duration`/)
    end
  end

  describe ".uri" do
    it "generates a url" do
      response = GovukSchemas::RandomContentGenerator.new.uri

      expect(response).to match(URI::DEFAULT_PARSER.make_regexp)

      uri = URI.parse(response)

      expect(uri.scheme).to eq("https")
    end
  end

  describe ".govuk_subdomain_url" do
    it "generates a uri" do
      response = GovukSchemas::RandomContentGenerator.new.govuk_subdomain_url

      expect(response).to match(URI::DEFAULT_PARSER.make_regexp)

      uri = URI.parse(response)

      expect(uri.host&.end_with?(".gov.uk")).to be true
    end
  end

  describe ".string_for_regex" do
    let(:random_content_generator) { GovukSchemas::RandomContentGenerator.new }

    it "generates a valid base path" do
      input_pattern = "^/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?$"
      additional_required_pattern = "^/.{0,511}$"
      result = random_content_generator.string_for_regex(input_pattern)

      expect(result).to match(/#{input_pattern}/)
      expect(result).to match(/#{additional_required_pattern}/)
    end

    it "generates a content block order item" do
      pattern = "^addresses|contact_links|email_addresses|telephones.[a-z0-9]+(?:-[a-z0-9]+)*$"
      result = random_content_generator.string_for_regex(pattern)

      expect(result).to match(/#{pattern}/)
    end
  end
end
