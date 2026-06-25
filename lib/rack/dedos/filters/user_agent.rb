# frozen_string_literal: true

module Rack
  module Dedos
    module Filters
      class UserAgent < Base

        def name
          :user_agent
        end

        # @option options [Integer] :cache_period how long to retain cached IP
        #   addresses in seconds (default: 900)
        def initialize(...)
          super
          @cache_period = options[:cache_period] || 900
        end

        def allowed?(request, ip)
          case cache.get(ip)
          when nil              # first contact
            cache.set(ip, request.user_agent, expires_in: @cache_period)
            true
          when 'BLOCKED'        # already blocked
            false
          when request.user_agent   # user agent hasn't changed
            true
          else   # user agent has changed
            cache.set(ip, 'BLOCKED', expires_in: @cache_period)
            false
          end
        rescue => error
          logger.error("request from #{ip} allowed due to error: #{error.message}")
          true
        end

      end
    end
  end
end
