# frozen_string_literal: true

module Rack
  module Dedos
    module Filters
      class Base

        DEFAULT_OPTIONS = {
          status: 403,
          text: 'Forbidden (Temporarily Blocked by Rules)'
        }

        attr_reader :app
        attr_reader :options

        # @param app [#call]
        # @param options [Hash{Symbol => Object}]
        def initialize(app, options = {})
          @app = app
          @options = DEFAULT_OPTIONS.merge(options)
        end

        def call(env)
          request = Rack::Request.new(env)
          ip = real_ip(request)
          if allowed?(request, ip)
            app.call(env)
          else
            warn("rack-dedos: request from #{ip} blocked by #{self.class} `#{@country_code.inspect}'")
            [options[:status], { 'Content-Type' => 'text/plain' }, [options[:text]]]
          end
        end

        private

        def config
          Rack::Dedos.config
        end

        # Get the real IP of the client
        #
        # If a proxy such as Cloudflare is in the mix, the client IP reported
        # by Rack may be wrong. Therefore, we determine the real client IP
        # using the following priorities:
        #
        # 1. Cf-Connecting-Ip header
        # 2. X-Forwarded-For header (also remove port number)
        # 3. IP reported by Rack
        #
        # @param request [Rack::Request]
        # @return [String, nil] real client IP or +nil+ if X-Forwarded-For is
        #   not set
        def real_ip(request)
          case
          when ip = request.get_header('HTTP_CF_CONNECTING_IP')
            ip
          when forwarded_for = request.forwarded_for
            forwarded_for.split(/\s*,\s*/).first&.sub(/:\d+$/, '')
          else
            request.ip
          end
        end

      end
    end
  end
end
