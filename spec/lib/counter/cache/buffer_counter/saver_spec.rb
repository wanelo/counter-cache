require 'spec_helper'

RSpec.describe Counter::Cache::Counters::BufferCounter::Saver do
  class Boo
  end

  let(:relation_object) { double(boo_count: 2) }
  let(:options) { double(relation_class_name: "Boo", relation_id: 1, column: "boo_count", method: nil, source_object_class_name: Boo) }
  let(:saver) { Counter::Cache::Counters::BufferCounter::Saver.new(options) }

  describe '#save!' do
    let(:counting_store) { double(get: nil) }

    before do
      allow(Boo).to receive(:find_by_id).and_return(relation_object)
      allow(Counter::Cache.configuration).to receive(:counting_data_store).and_return(counting_store)
    end

    describe "yielding" do
      let(:counting_store) { double(get: 2) }

      before do
        allow(options).to receive(:cache?).and_return(true)
        expect(relation_object).to receive(:boo_count=).with(4)
        expect(relation_object).to receive(:save!)
        expect(counting_store).to receive(:del)
      end

      describe "with block" do
        it "yields" do
          expect { |b| saver.save!(&b) }.to yield_with_args(2, 4, relation_object, "boo_count")
        end
      end
    end

    describe 'when cache? is true' do
      let(:counting_store) { double(get: 2) }

      before do
        allow(options).to receive(:cache?).and_return(true)
        expect(counting_store).to receive(:del)
      end

      it 'saves the value' do
        expect(relation_object).to receive(:boo_count=).with(4)
        expect(relation_object).to receive(:save!)
        saver.save!
      end
    end

    describe 'when cache? is false' do
      before do
        allow(options).to receive(:cache?).and_return(false)
      end

      describe 'when method is passed' do
        before do
          allow(options).to receive(:method).and_return("call_this_thing")
          allow(relation_object).to receive(:call_this_thing).and_return(4)
        end

        it 'saves the value' do
          expect(relation_object).to receive(:boo_count=).with(4)
          expect(relation_object).to receive(:save!)
          saver.save!
        end
      end

      describe 'when method is not passed' do

        before do
          allow(Boo).to receive(:table_name).and_return("boos")
          allow(relation_object).to receive(:boos).and_return(double(count: 4))
        end

        it 'saves the value' do
          expect(relation_object).to receive(:boo_count=).with(4)
          expect(relation_object).to receive(:save!)
          saver.save!
        end
      end
    end
  end
end
