# frozen_string_literal: true

module Rack
  module Dedos
    class Factory
      class << self

        def app
          ->(env) { [200, {}, 'success'] }
        end

        def env(ip, user_agent='firefox')
          Rack::MockRequest.env_for(
            '/',
            { 'REMOTE_ADDR' => ip, 'HTTP_USER_AGENT' => user_agent }
          )
        end

      end
    end
  end
end
