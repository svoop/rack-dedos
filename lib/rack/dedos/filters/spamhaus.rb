# frozen_string_literal: true

require 'resolv'

module Rack
  module Dedos
    module Filters
      class Spamhaus < Base

        QUERY_DOMAIN = 'zen.spamhaus.org'.freeze

        def name
          :spamhaus
        end

        def initialize(...)
          super
          @resolver = ConnectionPool.new(size: 5, timeout: 1) do
            Resolv::DNS.new.tap { _1.timeouts = [1, 2] }
          end
        end

        def allowed?(request, ip)
          @resolver.with do |resolver|
            resolver.getresources(domain_for(ip), Resolv::DNS::Resource::IN::A).empty?
          end
        rescue => error
          logger.error("request from #{ip} allowed due to error: #{error.message}")
          true
        end

        private

        def domain_for(ip)
          ip.split('.').reverse.join('.').concat('.', QUERY_DOMAIN)
        end

      end
    end
  end
end
