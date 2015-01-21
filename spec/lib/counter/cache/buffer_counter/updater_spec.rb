require 'spec_helper'

RSpec.describe Counter::Cache::Counters::BufferCounter::Updater do
  let(:options) { double(relation: "boo", relation_class_name: "Boo", column: "boo", relation_id: nil, increment_by: 1) }
  let(:source_object) { double(boo_id: 1) }
  let(:updater) { Counter::Cache::Counters::BufferCounter::Updater.new(source_object, options, "Hello") }

  describe "#update" do
    describe "when valid" do
      it "sends direction and enqueues" do
        expect(updater).to receive(:valid?) { true }
        expect(updater).to receive(:decr) { true }
        expect(updater).to receive(:enqueue) { true }
        updater.update!(:decr)
      end
    end

    describe "when invalid" do
      it "sends direction and enqueues" do
        expect(updater).to receive(:valid?) { false }
        expect(updater).to receive(:decr).never
        expect(updater).to receive(:enqueue).never
        updater.update!(:decr)
      end
    end
  end

  describe "#enqueue" do
    it 'constructs and calls enqueue! on the enqueue' do
      expect(Counter::Cache::Counters::BufferCounter::Enqueuer).to receive(:new).with(options,
                                                                                      source_object.class.name,
                                                                                      1,
                                                                                      "Boo",
                                                                                      "Hello")
                                                                                .and_return(double(enqueue!: true))
      updater.send(:enqueue)
    end
  end

  describe "#decr" do
    it 'calls decr on the redis instance' do
      expect_any_instance_of(Counter::Cache::Redis).to receive(:decr)
      updater.send(:decr)
    end
  end

  describe "#incr" do
    it 'calls decr on the redis instance' do
      expect_any_instance_of(Counter::Cache::Redis).to receive(:incr)
      updater.send(:incr)
    end
  end

  describe "valid?" do
    describe "With no if value" do
      let(:options) { double(relation: "boo", if_value: nil, relation_id: nil) }

      describe 'with relation_id' do
        let(:source_object) { double(boo_id: 123) }

        it 'returns true' do
          expect(updater.send(:valid?)).to eq(true)
        end
      end

      describe 'without relation_id' do
        let(:source_object) { double(boo_id: nil) }

        it 'returns false' do
          expect(updater.send(:valid?)).to eq(false)
        end
      end
    end

    describe "With if object" do
      let(:source_object) { double(boo_id: 123) }
      let(:options) { double(relation: "boo", if_value: if_value, relation_id: nil) }

      describe 'if value returns false' do
        let(:if_value) { double(call: true) }

        it 'returns true' do
          expect(updater.send(:valid?)).to eq(true)
        end
      end

      describe 'if value returns true' do
        let(:if_value) { double(call: false) }

        it 'returns false' do
          expect(updater.send(:valid?)).to eq(false)
        end
      end
    end
  end
end
