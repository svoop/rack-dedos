# frozen_string_literal: true

require 'logger'

module Rack
  module Dedos
    module Filters
      class Base

        DEFAULT_OPTIONS = {
          logger: nil,
          only_paths: [],
          except_paths: [],
          status: 403,
          text: 'Forbidden (Temporarily Blocked by Rules)',
          headers: []
        }.freeze

        attr_reader :app, :options, :details

        # @param app [#call]
        # @param options [Hash{Symbol => Object}]
        def initialize(app, options={})
          @app = app
          @options = DEFAULT_OPTIONS.merge(options)
          @details = {}
        end

        def call(env)
          request = Rack::Request.new(env)
          ip = real_ip(request)
          if !apply?(request) || allowed?(request, ip)
            app.call(env)
          else
            message = ["request #{request.path} from #{ip} blocked by #{name}"]
            message += details_list
            message += headers_list(request)
            logger.info(message.join(' '))
            [options[:status], { 'Content-Type' => 'text/plain' }, [options[:text]]]
          end
        end

        private

        def config
          Rack::Dedos.config
        end

        def logger
          @logger ||= options[:logger] || ::Logger.new($stdout, progname: 'rack-dedos')
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

        def details_list
          details.map do |key, value|
            "#{key.upcase}=#{value.inspect}"
          end
        end

        def headers_list(request)
          options[:headers].map do |header|
            "#{header.upcase}=#{request.get_header(header).inspect}"
          end
        end
      end
    end
  end
end
