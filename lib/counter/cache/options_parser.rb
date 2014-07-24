module Counter
  module Cache
    class OptionsParser < Struct.new(:options)
      def worker_adapter
        options[:worker_adapter] || Counter::Cache.configuration.default_worker_adapter
      end

      def source_object_class_name
        options[:source_object_class_name]
      end

      def column
        options[:column]
      end

      def relation
        options[:relation]
      end

      def relation_class_name
        options[:relation_class_name]
      end

      def relation_id
        options[:relation_id]
      end

      def method
        options[:method]
      end

      def cached?
        option_or_true options[:cache]
      end

      def recalculation?
        option_or_true options[:recalculation]
      end

      def polymorphic?
        options[:polymorphic]
      end

      def if_value
        options[:if]
      end

      def wait(source_object)
        wait = options[:wait]
        if wait.respond_to?(:call)
          wait.call(source_object)
        else
          wait
        end
      end

      def custom_options(source_object)
        if options[:custom_options]
          custom_options = {}
          options[:custom_options].each do |option_name, option_value|
            if option_value.respond_to?(:call)
              custom_options[option_name] = option_value.call(source_object)
            else
              custom_options[option_name] = option_value
            end
          end
          return custom_options
        else
          nil
        end
      end

      def recalculation_delay
        options[:recalculation_delay] || Counter::Cache.configuration.recalculation_delay
      end

      protected

      def option_or_true(val)
        val || val.nil?
      end

    end
  end
end
