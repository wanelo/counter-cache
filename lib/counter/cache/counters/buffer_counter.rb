require 'counter/cache/counters/buffer_counter/updater'
require 'counter/cache/counters/buffer_counter/saver'

module Counter
  module Cache
    module Counters
      class BufferCounter
        attr_accessor :source_object, :options

        def initialize(source_object, options)
          @options = Counter::Cache::OptionsParser.new(options)
          @source_object = source_object
        end

        def update(direction)
          Updater.new(source_object, options, self.class.name).update!(direction)
        end

        def save!
          Saver.new(options).save!
        end
      end
    end
  end
end
