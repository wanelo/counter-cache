require 'spec_helper'

RSpec.describe Counter::Cache::Counters::BufferCounter::Key do
  let(:options) { double(relation_class_name: "Boo", relation: "boo", column: "boos_count", column_key_name: nil, relation_key_name: nil, relation_id: nil) }
  let(:source_object) { double(boo_id: 1) }
  let(:key) { Counter::Cache::Counters::BufferCounter::Key.new(source_object, options) }

  describe '#to_s' do
    it 'returns the key with the class, id, and column' do
      expect(key.to_s).to eq("cc:Bo:1:boos")
    end

    context 'with column_key_name override' do
      let(:options) { double(relation_class_name: "Boo", relation: "boo", column_key_name: "boos_count", relation_key_name: nil, relation_id: nil) }
      it 'returns the key with the class, id, and column override' do
        expect(key.to_s).to eq("cc:Bo:1:boos_count")
      end
    end

    context 'with relation_key_name override' do
      let(:options) { double(relation_class_name: "Boo", relation: "boo", column_key_name: "boos_count", relation_key_name: "my_relation", relation_id: nil) }
      it 'returns the key with the class, id, and column override' do
        expect(key.to_s).to eq("cc:my_relation:1:boos_count")
      end
    end
  end
end
