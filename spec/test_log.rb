require 'stringio'
require 'logger'

class TestLog
  attr_reader :logger

  def initialize
    @io = StringIO.new
    @logger = Logger.new(@io)
    @logger.formatter = ->(s, _, _, m) { "#{s} -- #{m}\n" }
  end

  def clear
    @io.truncate(0)
    @io.pos = 0
    self
  end

  def read
    @io.rewind
    @io.read.strip
  end
end
