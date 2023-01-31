# frozen_string_literal: true

module Rack
  module Dedos
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
        if allowed?(request)
          app.call(env)
        else
          warn("rack-dedos: request from #{request.ip} blocked by #{self.class}")
          [options[:status], { 'Content-Type' => 'text/plain' }, [options[:text]]]
        end
      end

      private

      def config
        Rack::Dedos.config
      end

    end
  end
end
