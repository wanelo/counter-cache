module Counter
  module Cache
    class Config
      attr_accessor :default_worker_adapter, :recalculation_delay, :redis_pool
    end
  end
end
