# frozen_string_literal: true

module Rack
  module Dedos
    module Filters
      class UserAgent < Base

        # @option options [String] :cache_url URL of the cache backend
        # @option options [Integer] :cache_period how long to retain cached IP
        #   addresses in seconds (default: 900)
        def initialize(*)
          super
          @cache_url = options[:cache_url] or fail "cache URL not set"
          @cache_period = options[:cache_period] || 900
          @cache_key_prefix = options[:cache_key_prefix]
          cache   # hit once to fail on errors at boot
        end

        def allowed?(request, ip)
          case cache.get(ip)
          when nil              # first contact
            cache.set(ip, request.user_agent)
            true
          when 'BLOCKED'        # already blocked
            false
          when request.user_agent   # user agent hasn't changed
            true
          else                  # user agent has changed
            cache.set(ip, 'BLOCKED')
            false
          end
        rescue => error
          warn("rack-dedos: request from #{ip} allowed due to error: #{error.message}")
          true
        end

        private

        def cache
          config[:cache] ||= Cache.new(
            url: @cache_url,
            expires_in: @cache_period,
            key_prefix: @cache_key_prefix
          )
        end

      end
    end
  end
end
