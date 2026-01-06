# frozen_string_literal: true

gem 'minitest'

require 'debug'
require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'rack', 'dedos')

require Pathname(__dir__).join('..', 'lib', 'rack', 'dedos', 'filters', 'country')
require Pathname(__dir__).join('..', 'lib', 'rack', 'dedos', 'filters', 'user_agent')

require 'minitest/mock'
require 'minitest/flash'
require 'minitest/focus'

require Pathname(__dir__).join('factory')

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

$warnings = []
module WarningFilter
  def warn(message)
    if message.match?(/^rack-dedos:/)
      $warnings << message.chomp
    else
      super
    end
  end
end
Warning.extend WarningFilter
