require 'spec_helper'

describe Counter::Cache do
  describe '.included' do
    let(:counter) { double(:counter) }
    let(:clazz) { Class.new { include Counter::Cache } }

    it 'listens to the after_create and after_destroy' do
      expect(clazz).to receive(:after_create).with(an_instance_of(Counter::Cache::ActiveRecordUpdater)).once { true }
      expect(clazz).to receive(:after_destroy).with(an_instance_of(Counter::Cache::ActiveRecordUpdater)).once { true }
      clazz.counter_cache_on :counter => counter
    end
  end
end
