require 'spec_helper'

describe Counter::Cache::Updater do
  let(:counter_class) { double }
  let(:counter) { double }
  let(:options) { { counter_class: counter_class } }
  subject { Counter::Cache::Updater.new(options) }

  let(:record) { double }

  describe "#after_create" do
    it "Calls update on counter instance" do
      expect(counter).to receive(:update).with(:incr)
      expect(counter_class).to receive(:new).with(record, options).and_return(counter)
      subject.after_create(record)
    end
  end

  describe "#after_destroy" do
    it "Calls update on counter instance" do
      expect(counter).to receive(:update).with(:decr)
      expect(counter_class).to receive(:new).with(record, options).and_return(counter)
      subject.after_destroy(record)
    end
  end
end
