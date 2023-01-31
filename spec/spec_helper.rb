# frozen_string_literal: true

gem 'minitest'

require 'debug'
require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'rack', 'dedos')

require 'minitest/sound'
Minitest::Sound.success = Pathname(__dir__).join('sounds', 'success.mp3').to_s
Minitest::Sound.failure = Pathname(__dir__).join('sounds', 'failure.mp3').to_s

require 'minitest/focus'
require Pathname(__dir__).join('factory')

class MiniTest::Spec
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

Integer.infect_an_assertion :assert_equals_status, :must_equal_status
String.infect_an_assertion :assert_equals_text, :must_equal_text

$warning_counter = 0
module WarningFilter
  def warn(message, category: nil, **kwargs)
    if message.match?(/^rack-dedos:/)
      $warning_counter += 1
    else
      super
    end
  end
end
Warning.extend WarningFilter
