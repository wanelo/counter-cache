module Counter
  module Cache
    module Counters
      class BufferCounter
        class Key < Struct.new(:source_object, :options)
          def to_s
            "cc:#{relation_finder.relation_class.to_s[0..1]}:#{relation_finder.relation_id}:#{column}"
          end

          protected

          def column
            options.column.to_s.gsub(/_count/, '')
          end

          def relation_finder
            RelationFinder.new(source_object, options)
          end
        end
      end
    end
  end
end
