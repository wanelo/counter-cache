require 'spec_helper'

RSpec.describe Counter::Cache::Counters::BufferCounter::RelationFinder do
  let(:options) { double }
  let(:source_object) { double }
  let(:finder) { Counter::Cache::Counters::BufferCounter::RelationFinder.new(source_object, options) }

  describe '#relation_class' do
    context 'when relation_class_name is present' do
      let(:options) { double(relation_class_name: "Boo") }

      it 'returns the relation_class_name' do
        expect(finder.relation_class).to eq("Boo")
      end
    end

    context 'when polymorphic?' do
      let(:options) { double(polymorphic?: true, relation: "boo", relation_class_name: nil) }
      let(:source_object) { double(boo_type: "Boo") }

      it 'asks for the type' do
        expect(finder.relation_class).to eq("Boo")
      end
    end

    context 'no relation_class_name or polymorphic' do
      let(:options) { double(relation_class_name: nil, polymorphic?: false, relation: "boo") }

      before do
        reflection = double
        expect(reflection).to receive_message_chain("class_name.to_s.camelize") { "Boo" }
        expect(source_object).to receive(:reflections).and_return({:boo => reflection})
      end

      it 'asks active record for the class name' do
        expect(finder.relation_class).to eq("Boo")
      end
    end
  end

  describe '#relation_id' do
    let(:options) { double(relation: "boo", relation_id: nil) }
    let(:source_object) { double(boo_id: 123) }

    it 'calls relation_id on the source object' do
      expect(finder.relation_id).to eq(123)
    end
  end
end
