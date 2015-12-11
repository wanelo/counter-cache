require 'spec_helper'

RSpec.describe Counter::Cache::Counters::BufferCounter::Enqueuer do
  let(:worker_adapter) { double }
  let(:options) { double(worker_adapter: worker_adapter,
                         wait: 10,
                         column: "boo",
                         touch_column: "boo_updated_at",
                         method: "calculate_boo",
                         cached?: true,
                         recalculation?: false,
                         recalculation_delay: 20) }

  let(:source_object_class_name) { "BooUser" }
  let(:relation_id) { 1 }
  let(:relation_type) { "Boo" }

  let(:enqueuer) { Counter::Cache::Counters::BufferCounter::Enqueuer.new(options, source_object_class_name, relation_id, relation_type, "SuperCounter") }

  describe '#enqueue' do
    before do
      expect(worker_adapter).to receive(:enqueue).with(10,
                                                       "BooUser",
                                                       { relation_class_name: "Boo",
                                                         relation_id: 1,
                                                         column: "boo",
                                                         touch_column: "boo_updated_at",
                                                         method: "calculate_boo",
                                                         cache: true,
                                                         counter: "SuperCounter" })
    end

    describe 'when recalculation is true' do
      before do
        expect(options).to receive(:recalculation?).and_return(true)
      end

      it "enqueues two jobs" do
        expect(worker_adapter).to receive(:enqueue).with(20,
                                                         "BooUser",
                                                         { relation_class_name: "Boo",
                                                           relation_id: 1,
                                                           column: "boo",
                                                           touch_column: "boo_updated_at",
                                                           method: "calculate_boo",
                                                           cache: false,
                                                           counter: "SuperCounter" })
        enqueuer.enqueue!(double)
      end
    end

    it 'enqueues one job' do
      enqueuer.enqueue!(double)
    end
  end
end
