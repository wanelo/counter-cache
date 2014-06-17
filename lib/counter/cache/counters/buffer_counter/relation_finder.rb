module Counter
  module Cache
    module Counters
      class BufferCounter
        class RelationFinder < Struct.new(:source_object, :options)
          def relation_class
            return options.relation_class_name if options.relation_class_name
            return polymorphic_type if options.polymorphic?
            reflection_type
          end

          def relation_id
            options.relation_id || source_object.send("#{options.relation}_id")
          end

          private

          def polymorphic_type
            source_object.send("#{options.relation}_type")
          end

          def reflection_type
            source_object.reflections[options.relation.to_sym].class_name.to_s.camelize # let AR give us the correct class name :)
          end
        end
      end
    end
  end
end
