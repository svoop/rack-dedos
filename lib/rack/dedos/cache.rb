# frozen_string_literal: true

module Rack
  module Dedos
    class Cache

      def initialize(url:, key_prefix: nil, expires_in: 86400)
        @url, @key_prefix, @expires_in = url, key_prefix, expires_in
        type = url.split(':').first
        extend Object.const_get("Rack::Dedos::Cache::#{type.capitalize}")
        connect
      rescue NameError
        raise(ArgumentError, "type of cache for `#{@url}' not supported")
      end

      module Hash
        def set(key, value, expires_in: @expires_in)
          expires_at = now + expires_in if expires_in
          @store[key] = [value, expires_at]
        end

        def get(key)
          if (value, expires_at = @store[key])
            if !expires_at || expires_at > now
              value
            else
              @store.delete(key)
              nil
            end
          end
        end

        private

        def connect
          @store = {}
        end

        def now
          Time.now.to_i
        end
      end

      module Redis
        require 'redis'

        def set(key, value, expires_in: @expires_in)
          @store.with { _1.set(prefixed(key), value, ex: expires_in) }
        end

        def get(key)
          @store.with { _1.get(prefixed(key)) }
        end

        private

        def connect
          @store = ConnectionPool.new(size: 5, timeout: 1) do
            ::Redis.new(url: @url)
          end
        end

        def prefixed(key)
          @key_prefix ? "#{@key_prefix}:#{key}" : key
        end
      end

    end
  end
end
