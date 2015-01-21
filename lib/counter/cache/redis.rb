module Counter
  module Cache
    class Redis
      def incr(key, val = 1)
        with_redis do |redis|
          redis.incrby key, val
        end
      end

      def decr(key, val = 1)
        with_redis do |redis|
          redis.decrby(key, val)
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
        redis_pool = Counter::Cache.configuration.redis_pool
        return yield redis_pool unless redis_pool.respond_to?(:with)

        redis_pool.with do |redis|
          yield redis
        end
      end
    end
  end
end
