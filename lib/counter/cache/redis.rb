module Counter
  module Cache
    class Redis
      def incr(key)
        with_redis do |redis|
          redis.incr key
        end
      end

      def decr(key)
        with_redis do |redis|
          redis.decr(key)
        end
      end

      def get(key)
        with_redis do |redis|
          redis.get(key)
        end
      end

      def del(key)
        with_redis do |redis|
          redis.del(key)
        end
      end

      private

      def with_redis
        Counter::Cache.configuration.redis_pool.with do |redis|
          yield redis
        end
      end
    end
  end
end
