require "spec_helper"

RSpec.describe GovukSchemas::Example do
  describe ".find_all" do
    it "returns all the examples" do
      examples = GovukSchemas::Example.find_all("call_for_evidence")

      expect(examples).to be_a(Array)
      expect(examples.size > 1).to eql(true)
    end
  end

  describe ".find" do
    it "returns one example" do
      example_content_item = GovukSchemas::Example.find("call_for_evidence", example_name: "call_for_evidence_outcome")

      expect(example_content_item).to be_a(Hash)
    end
  end

  describe ".examples_path" do
    let(:in_examples) { false }
    let(:schema_name) { "call_for_evidence" }
    before do
      allow(Dir)
        .to receive(:exist?)
        .with("#{GovukSchemas.content_schema_dir}/examples")
        .and_return(in_examples)
    end

    subject { described_class.examples_path(schema_name) }

    context "when schema examples are in /examples" do
      let(:in_examples) { true }
      it { is_expected.to eq "#{GovukSchemas.content_schema_dir}/examples/#{schema_name}/frontend" }
    end

    context "when schema examples are not in /examples" do
      let(:in_examples) { false }
      it { is_expected.to eq "#{GovukSchemas.content_schema_dir}/formats/#{schema_name}/frontend/examples" }
    end
  end
end
