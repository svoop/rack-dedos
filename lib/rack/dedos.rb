# frozen_string_literal: true

require 'rack'

require_relative 'dedos/version'

module Rack
  module Dedos
    lib_dir = ::File.expand_path(::File.dirname(__FILE__))
    autoload :Cache, lib_dir + '/dedos/cache'
    autoload :Base, lib_dir + '/dedos/base'
    autoload :UserAgent, lib_dir + '/dedos/user_agent'
    autoload :Country, lib_dir + '/dedos/country'

    class << self
      def config
        @config ||= {}
      end

      def new(app, options = {})
        except = Array options[:except]

        Rack::Builder.new do
          use(::Rack::Dedos::UserAgent, options) unless except.include? :user_agent
          use(::Rack::Dedos::Country, options) unless except.include? :country
          run app
        end.to_app
      end
    end
  end
end
