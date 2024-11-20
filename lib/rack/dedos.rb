# frozen_string_literal: true

require 'rack'

require_relative 'dedos/version'

module Rack
  module Dedos

    require_relative 'dedos/cache'
    require_relative 'dedos/filters/base'

    class << self
      def config
        @config ||= {}
      end

      def new(app, options = {})
        except = Array options[:except]

        Rack::Builder.new do
          unless except.include? :user_agent
            require_relative 'dedos/filters/user_agent'
            use(::Rack::Dedos::Filters::UserAgent, options)
          end
          unless except.include? :country
            require_relative 'dedos/filters/country'
            use(::Rack::Dedos::Filters::Country, options)
          end
          run app
        end.to_app
      end
    end
  end
end
