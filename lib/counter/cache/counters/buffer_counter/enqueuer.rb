module Counter
  module Cache
    module Counters
      class BufferCounter
        class Enqueuer < Struct.new(:options, :source_object_class_name, :relation_id, :relation_class, :counter_class_name)
          def enqueue!(source_object)
            create_and_enqueue(options.wait(source_object), options.cached?)
            create_and_enqueue(options.recalculation_delay, false) if options.recalculation?
          end

          private

          def create_and_enqueue(delay, cached)
            options.worker_adapter.enqueue(delay,
                                           source_object_class_name,
                                           { relation_class_name: relation_class,
                                             relation_id: relation_id,
                                             column: options.column,
                                             touch_column: options.touch_column,
                                             method: options.method,
                                             cache: cached,
                                             counter: counter_class_name })
          end
        end
      end
    end
  end
end
