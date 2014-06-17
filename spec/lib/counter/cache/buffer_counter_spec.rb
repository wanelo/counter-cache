require 'spec_helper'

RSpec.describe Counter::Cache::Counters::BufferCounter do
  let(:options) { {} }
  let(:source_object) { double }
  let(:counter) { Counter::Cache::Counters::BufferCounter.new(source_object, options) }

  describe "#update" do
    it "calls update! on an instance of an updater" do
      updater = double
      expect(updater).to receive(:update!).with(:blah)
      expect(Counter::Cache::Counters::BufferCounter::Updater).to receive(:new).with(source_object,
                                                                            an_instance_of(Counter::Cache::OptionsParser),
                                                                            "Counter::Cache::Counters::BufferCounter").and_return(updater)
      counter.update(:blah)
    end
  end

  describe "#save!" do
    it "calls save! on an instance of a saver" do
      saver = double
      expect(saver).to receive(:save!)
      expect(Counter::Cache::Counters::BufferCounter::Saver).to receive(:new).with(an_instance_of(Counter::Cache::OptionsParser)).and_return(saver)
      counter.save!
    end
  end
end
