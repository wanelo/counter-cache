module Counter
  module Cache
    module Counters
      class BufferCounter
        class Enqueuer < Struct.new(:options, :source_object_class_name, :relation_id, :relation_class, :counter_class_name)
          def enqueue!(source_object)
            create_and_enqueue(options.wait(source_object), options.cached?, source_object)
            create_and_enqueue(options.recalculation_delay, false, source_object) if options.recalculation?
          end

          private

          def create_and_enqueue(delay, cached, source_object)
            options.worker_adapter.enqueue(delay,
                                           source_object_class_name,
                                           { relation_class_name: relation_class,
                                             relation_id: relation_id,
                                             column: options.column,
                                             method: options.method,
                                             cache: cached,
                                             counter: counter_class_name,
                                             custom_options: options.custom_options(source_object)
                                            }
                                          )
          end
        end
      end
    end
  end
end
