module Rack
  module Dedos
    class Cache

      def initialize(url:, expires_in: nil, key_prefix: nil)
        @url, @expires_in = url, expires_in
        @key_prefix = ("#{key_prefix}:" if key_prefix).to_s
        type = url.split(':').first
        extend Object.const_get("Rack::Dedos::Cache::#{type.capitalize}")
      rescue NameError
        raise(ArgumentError, "type of cache for `#{@url}' not supported")
      end

      module Hash
        def store
          @store ||= {}
        end

        def set(key, value)
          store[key] = [value, timestamp]
        end

        def get(key)
          if (value, created_at = store[key])
            if !@expires_in || @expires_in >= timestamp - created_at
              value
            else
              store.delete(key)
              nil
            end
          end
        end

        private

        def timestamp
          Time.now.to_i
        end
      end

      module Redis
        require 'redis'

        def store
          @store ||= ::Redis.new(url: @url)
        end

        def set(key, value)
          store.set(@key_prefix + key, value, ex: @expires_in)
        end

        def get(key)
          store.get(@key_prefix + key)
        end
      end

    end
  end
end
