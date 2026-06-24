# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Rack::Dedos::Filters::Country do
  before do
    Rack::Dedos.config.clear
  end

  subject do
    Rack::Dedos::Filters::Spamhaus.new(factory.app,
      logger: $test_log.clear.logger
    )
  end

  describe :allowed? do
    it "denies listed IPs" do
      _(subject.call(factory.env('127.0.0.2'))).must_equal_status 403
    end

    it "allows unlisted IPs" do
      _(subject.call(factory.env('1.1.1.1'))).must_equal_status 200
    end

    it "enters the rescue fallback on errors" do
      _(subject.call(factory.env('a.b.c.d'))).must_equal_status 200
    end
  end
end
