# frozen_string_literal: true

module Rack
  module Dedos
    module Filters
      class Base

        DEFAULT_OPTIONS = {
          only_paths: [],
          except_paths: [],
          status: 403,
          text: 'Forbidden (Temporarily Blocked by Rules)'
        }.freeze

        attr_reader :app
        attr_reader :options
        attr_reader :details

        # @param app [#call]
        # @param options [Hash{Symbol => Object}]
        def initialize(app, options = {})
          @app = app
          @options = DEFAULT_OPTIONS.merge(options)
          @details = nil
        end

        def call(env)
          request = Rack::Request.new(env)
          ip = real_ip(request)
          if !apply?(request) || allowed?(request, ip)
            app.call(env)
          else
            message = "rack-dedos: request #{request.path} from #{ip} blocked by #{self.class}"
            warn([message, details].compact.join(": "))
            [options[:status], { 'Content-Type' => 'text/plain' }, [options[:text]]]
          end
        end

        private

        def config
          Rack::Dedos.config
        end

        def apply?(request)
          return false if @options[:except_paths].any? { request.path.match? _1 }
          return true if @options[:only_paths].none?
          @options[:only_paths].any? { request.path.match? _1 }
        end

        # Get the real IP of the client
        #
        # If containers and/or proxies such as Cloudflare are in the mix, the
        # client IP reported by Rack may be wrong. Therefore, we determine the
        # real client IP using the following priorities:
        #
        # 1. Cf-Connecting-Ip header
        # 2. X-Forwarded-For header (also remove port number)
        # 3. IP reported by Rack
        #
        # @param request [Rack::Request]
        # @return [String] real client IP
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
