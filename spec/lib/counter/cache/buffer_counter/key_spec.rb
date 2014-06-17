require 'spec_helper'

describe Counter::Cache::Counters::BufferCounter::Key do
  let(:options) { double(relation_class_name: "Boo", relation: "boo", column: "boos_count", relation_id: nil) }
  let(:source_object) { double(boo_id: 1) }
  let(:key) { Counter::Cache::Counters::BufferCounter::Key.new(source_object, options) }

  describe '#to_s' do
    it 'returns the key with the class, id, and column' do
      expect(key.to_s).to eq("cc:Bo:1:boos")
    end
  end
end
