require 'spec_helper'

RSpec.describe Counter::Cache::Redis do
  let(:redis) { double }
  let(:redis_pool) { double }

  before do
    Counter::Cache.configure do |c|
      c.redis_pool = redis_pool
    end

    allow(redis_pool).to receive(:with).and_yield(redis)
  end

  let(:helper) { Counter::Cache::Redis.new }

  describe '#decr' do
    it 'calls decr on redis with the key' do
      expect(redis).to receive(:decrby).with("hello", 1)
      helper.decr("hello")
    end

    it 'calls decr on redis with the key and increment value' do
      expect(redis).to receive(:decrby).with("hello", 2)
      helper.decr("hello", 2)
    end
  end

  describe '#incr' do
    it 'calls incr on redis with the key' do
      expect(redis).to receive(:incrby).with("hello", 1)
      helper.incr("hello")
    end

    it 'calls incr on redis with the key and increment value' do
      expect(redis).to receive(:incrby).with("hello", 2)
      helper.incr("hello", 2)
    end
  end

  describe '#del' do
    it 'calls del on redis with the key' do
      expect(redis).to receive(:del).with("hello")
      helper.del("hello")
    end
  end

  describe '#get' do
    it 'calls get on redis with the key and returns the value' do
      expect(redis).to receive(:get).with("hello").and_return(2)
      expect(helper.get("hello")).to eq(2)
    end
  end
end
