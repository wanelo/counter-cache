module Counter
  module Cache
    class Config
      # TODO:: Confer with paul/kig about adapting the counting data store
      attr_accessor :default_worker_adapter, :recalculation_delay, :redis_pool, :counting_data_store

      def initialize
        self.counting_data_store = Counter::Cache::Redis.new
      end
    end
  end
end
