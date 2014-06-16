require "counter/cache/version"
require "counter/cache/updater"

module Counter
  module Cache
    def self.included(base)
      base.instance_eval do
        def counter_cache_on(options)
          after_create Updater.new(options)
          after_destroy Updater.new(options)
        end
      end
    end
  end
end
