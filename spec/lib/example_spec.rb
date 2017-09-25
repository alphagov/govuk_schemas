require 'spec_helper'

RSpec.describe GovukSchemas::Example do
  describe '.find_all' do
    it "returns all the examples" do
      examples = GovukSchemas::Example.find_all("specialist_document")

      expect(examples).to be_a(Array)
      expect(examples.size > 10).to eql(true)
    end
  end

  describe '.find' do
    it "returns one example" do
      example_content_item = GovukSchemas::Example.find("specialist_document", example_name: "drug-safety-update")

      expect(example_content_item).to be_a(Hash)
    end
  end

  describe ".examples_path" do
    let(:in_examples) { false }
    let(:schema_name) { "specialist_document" }
    before do
      allow(Dir)
        .to receive(:exist?)
        .with("#{GovukSchemas::CONTENT_SCHEMA_DIR}/examples")
        .and_return(in_examples)
    end

    subject { described_class.examples_path(schema_name) }

    context "when schema examples are in /examples" do
      let(:in_examples) { true }
      it { is_expected.to eq "#{GovukSchemas::CONTENT_SCHEMA_DIR}/examples/#{schema_name}/frontend" }
    end

    context "when schema examples are not in /examples" do
      let(:in_examples) { false }
      it { is_expected.to eq "#{GovukSchemas::CONTENT_SCHEMA_DIR}/formats/#{schema_name}/frontend/examples" }
    end
  end
end
