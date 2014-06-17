module Counter
  module Cache
    module Counters
      class BufferCounter
        class Saver < Struct.new(:options)
          def save!
            return unless relation_object

            old_value = current_column_value
            new_value = calculate_new_value

            save_new_value!(new_value)

            yield old_value, new_value, relation_object, options.column if block_given?
          end

          private

          def save_new_value!(value)
            relation_object.send("#{options.column}=", value)
            relation_object.save!(validate: false)
          end

          def calculate_new_value
            return current_column_value + counter_value.to_i if options.cached? && counter_value
            non_cached_count.to_i
          end

          def non_cached_count
            method = options.method
            return relation_object.send(method) if method && relation_object.respond_to?(method)
            relation_object.send(options.source_object_class_name.table_name).count
          end

          def current_column_value
            relation_object.send(options.column).to_i
          end

          def counter_value
            @counter_value ||= get.tap { |v| reset if v }
          end

          def get
            counting_data_store.get(key)
          end

          def reset
            counting_data_store.del(key)
          end

          def key
            Key.new(nil, options).to_s
          end

          def counting_data_store
            Counter::Cache.configuration.counting_data_store
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
