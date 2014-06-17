module Counter
  module Cache
    module Counters
      class BufferCounter
        class Saver < Struct.new(:options)
          def save!
            return unless relation_object
            old_value = current_relation_object_value

            counter_value = counter_value!
            new_value = if options.cache? && counter_value
                          current_relation_object_value + counter_value.to_i
                        else
                          non_cached_count
                        end.to_i

            relation_object.send("#{options.column}=", new_value)
            relation_object.save!

            # Wanelo::CounterCache::Event::Update.new(old_value, new_value, relation_object, options.column).fire!
          end

          private

          def non_cached_count
            method = options.method
            if method && relation_object.respond_to?(method)
              relation_object.send(method)
            else
              relation_object.send(options.source_object_class_name.table_name).count
            end.tap do # We need the actual count to return to be set to new_value
              reset
            end
          end

          def current_relation_object_value
            relation_object.send(options.column).to_i
          end

          def counter_value!
            get.tap do |value|
              reset if value
            end
          end

          def get
            redis.get(key)
          end

          def reset
            redis.del(key)
          end

          def key
            Key.new(nil, options).to_s
          end

          def redis
            Counter::Cache::Redis.new
          end

          def relation_object
            @relation_object ||= constantized_relation.find_by_id(options.relation_id)
          end

          def constantized_relation
            Object.const_get(options.relation_class_name)
          end
        end
      end
    end
  end
end
