require 'spec_helper'

describe Counter::Cache do
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
  end
end
