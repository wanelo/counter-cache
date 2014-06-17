module Counter
  module Cache
    class ActiveRecordUpdater < Struct.new(:options)
      def after_create(record)
        counter_for(record).update(:incr)
      end

      def after_destroy(record)
        counter_for(record).update(:decr)
      end

      private

      def counter_for(object)
        counter_class.new(object, options)
      end

      def counter_class
        options[:counter_class] || Counter::Cache::Counters::BufferCounter
      end
    end
  end
end
