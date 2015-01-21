require 'counter/cache/counters/buffer_counter/relation_finder'
require 'counter/cache/counters/buffer_counter/enqueuer'
require 'counter/cache/counters/buffer_counter/key'

module Counter
  module Cache
    module Counters
      class BufferCounter
        class Updater < Struct.new(:source_object, :options, :counter_class_name)
          def update!(direction)
            return unless valid?
            incr if direction == :incr
            decr if direction == :decr
            enqueue
          end

          private

          def enqueue
            Enqueuer.new(options,
                         source_object.class.name,
                         relation_finder.relation_id,
                         relation_finder.relation_class,
                         counter_class_name).enqueue!(source_object)
          end

          def relation_finder
            RelationFinder.new(source_object, options)
          end

          def valid?
            (!options.if_value || options.if_value.call(source_object)) && !relation_finder.relation_id.nil?
          end

          def incr
            redis.incr(key, increment_by)
          end

          def decr
            redis.decr(key, increment_by)
          end

          def increment_by
            return options.increment_by.call(source_object) if options.increment_by.is_a?(Proc)
            1
          end

          def key
            Key.new(source_object, options).to_s
          end

          def redis
            Counter::Cache::Redis.new
          end
        end
      end
    end
  end
end
