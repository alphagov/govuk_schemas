require 'spec_helper'

RSpec.describe GovukSchemas::Schema do
  describe '.find' do
    subject { GovukSchemas::Schema.find(type) }

    context "frontend_schema" do
      let(:type) { { frontend_schema: "detailed_guide" } }
      it 'returns a frontend schema by name' do
        expect(subject).to be_a(Hash)
      end
    end
  end

  describe '.type_location' do
    subject { GovukSchemas::Schema.type_location(schema) }

    context "frontend_schema" do
      let(:schema) { { frontend_schema: "detailed_guide" } }
      it 'returns the location' do
        expect(subject).to eq('detailed_guide/frontend/schema.json')
      end
    end

    context "links_schema" do
      let(:schema) { { links_schema: "detailed_guide" } }
      it 'returns the location' do
        expect(subject).to eq('detailed_guide/publisher_v2/links.json')
      end
    end

    context "publisher_schema" do
      let(:schema) { { publisher_schema: "detailed_guide" } }
      it 'returns the location' do
        expect(subject).to eq('detailed_guide/publisher_v2/schema.json')
      end
    end

    context "notification_schema" do
      let(:schema) { { notification_schema: "detailed_guide" } }
      it 'returns the location' do
        expect(subject).to eq('detailed_guide/notification/schema.json')
      end
    end
  end

  describe '.all' do
    subject { GovukSchemas::Schema.all }

    it 'returns all GOV.UK schemas' do
      expect(subject).to be_a(Hash)
    end
  end
end
