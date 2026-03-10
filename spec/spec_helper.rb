# frozen_string_literal: true

gem 'minitest'

require 'pathname'

require 'minitest/autorun'
require_relative '../lib/rack/dedos'

require_relative '../lib/rack/dedos/filters/country'
require_relative '../lib/rack/dedos/filters/user_agent'

require 'minitest/mock'

require_relative 'factory'
require_relative 'test_log'
$test_log = TestLog.new

Minitest.load_plugins

class Minitest::Spec
  class << self
    alias_method :context, :describe
  end

  def factory
    Rack::Dedos::Factory
  end
end

module Minitest::Assertions
  def assert_equals_status(expected, actual, msg=nil)
    msg = message(msg) { "Expected #{mu_pp(actual)} to have status #{mu_pp(expected)}" }
    assert(expected == actual.first, msg)
  end

  def assert_equals_text(expected, actual, msg=nil)
    msg = message(msg) { "Expected #{mu_pp(actual)} to have text #{mu_pp(expected)}" }
    assert(expected == actual.last.join("\n"), msg)
  end
end

module Minitest::Expectations
  infect_an_assertion :assert_equals_status, :must_equal_status
  infect_an_assertion :assert_equals_text,  :must_equal_text
end
