require 'spec_helper'

RSpec.describe Counter::Cache::Counters::BufferCounter::Enqueuer do
  let(:worker_adapter) { double }

  let(:source_object_class_name) { "BooUser" }
  let(:relation_id) { 1 }
  let(:relation_type) { "Boo" }

  describe '#enqueue' do
    context "without touch column" do
      before do
        @options =  double(worker_adapter: worker_adapter,
                           wait: 10,
                           column: "boo",
                           method: "calculate_boo",
                           cached?: true,
                           recalculation?: false,
                           recalculation_delay: 20)

        @enqueuer = Counter::Cache::Counters::BufferCounter::Enqueuer.new(@options, source_object_class_name, relation_id, relation_type, "SuperCounter")

        expect(worker_adapter).to receive(:enqueue).with(10,
                                                         "BooUser",
                                                         { relation_class_name: "Boo",
                                                           relation_id: 1,
                                                           column: "boo",
                                                           method: "calculate_boo",
                                                           cache: true,
                                                           counter: "SuperCounter" })
      end

      describe 'when recalculation is true' do
        before do
          expect(@options).to receive(:recalculation?).and_return(true)
        end

        it "enqueues two jobs" do
          expect(@options).to receive(:touch_column).twice
          expect(worker_adapter).to receive(:enqueue).with(20,
                                                           "BooUser",
                                                           { relation_class_name: "Boo",
                                                             relation_id: 1,
                                                             column: "boo",
                                                             method: "calculate_boo",
                                                             cache: false,
                                                             counter: "SuperCounter" })
          @enqueuer.enqueue!(double)
        end
      end

      it 'enqueues one job' do
        expect(@options).to receive(:touch_column)
        @enqueuer.enqueue!(double)
      end
    end

    context "with touch column" do
      before(:each) do
        @options = double(worker_adapter: worker_adapter,
                          wait: 10,
                          column: "boo",
                          touch_column: "boo_updated_at",
                          method: "calculate_boo",
                          cached?: true,
                          recalculation?: false,
                          recalculation_delay: 20)
        @enqueuer = Counter::Cache::Counters::BufferCounter::Enqueuer.new(@options, source_object_class_name, relation_id, relation_type, "SuperCounter")

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
          expect(@options).to receive(:recalculation?).and_return(true)
        end

        it "enqueues two jobs" do
          expect(@options).to receive(:touch_column).exactly(4).times
          expect(worker_adapter).to receive(:enqueue).with(20,
                                                           "BooUser",
                                                           { relation_class_name: "Boo",
                                                             relation_id: 1,
                                                             column: "boo",
                                                             touch_column: "boo_updated_at",
                                                             method: "calculate_boo",
                                                             cache: false,
                                                             counter: "SuperCounter" })
          @enqueuer.enqueue!(double)
        end
      end

      it 'enqueues one job' do
        expect(@options).to receive(:touch_column)
        @enqueuer.enqueue!(double)
      end
    end
  end
end
