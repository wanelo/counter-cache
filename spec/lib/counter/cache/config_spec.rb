require 'spec_helper'

RSpec.describe Counter::Cache do
  describe ".configure" do
    let(:clazz) { Class.new }

    it "sets counter class" do
      Counter::Cache.configure do |config|
        config.default_worker_adapter = clazz
      end
      expect(Counter::Cache.configuration.default_worker_adapter).to eq(clazz)
    end

    it "sets the redis connection" do
      Counter::Cache.configure do |config|
        config.redis_pool = clazz
      end
      expect(Counter::Cache.configuration.redis_pool).to eq(clazz)
    end

    describe "counting_data_store" do
      it "sets counting_data_store" do
        Counter::Cache.configure do |config|
          config.counting_data_store = clazz
        end
        expect(Counter::Cache.configuration.counting_data_store).to eq(clazz)
      end

      it "defaults to redis with no option" do
        expect(Counter::Cache.configuration.counting_data_store).to be_instance_of(Counter::Cache::Redis)
      end
    end


  end
end
