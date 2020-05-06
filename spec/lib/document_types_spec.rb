require "spec_helper"

RSpec.describe GovukSchemas::DocumentTypes do
  describe ".valid_document_types" do
    it "returns all valid document types" do
      valid_document_types = GovukSchemas::DocumentTypes.valid_document_types

      expect(valid_document_types).to be_a(Array)
      expect(valid_document_types).to include("guide")
    end
  end
end
