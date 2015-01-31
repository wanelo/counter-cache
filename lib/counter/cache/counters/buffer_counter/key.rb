module Counter
  module Cache
    module Counters
      class BufferCounter
        class Key < Struct.new(:source_object, :options)
          def to_s
            "cc:#{relation_class_key}:#{relation_finder.relation_id}:#{column}"
          end

          protected

          def relation_class_key
            options.relation_key_name || relation_finder.relation_class.to_s[0..1]
          end

          def column
            options.column_key_name || options.column.to_s.gsub(/_count/, '')
          end

          def relation_finder
            RelationFinder.new(source_object, options)
          end
        end
      end
    end
  end
end
