# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Rack::Dedos::Filters::UserAgent do
  before do
    Rack::Dedos.config.clear
    $warning_counter = 0
  end

  describe :allowed? do
    subject do
      Rack::Dedos::Filters::UserAgent.new(factory.app,
        cache_url: 'hash'
      )
    end

    it "doesn't enter the rescue fallback" do
      subject.call(factory.env('10.0.0.1', 'firefox'))
      _($warning_counter).must_be :zero?
    end

    it "allows the request on first contact" do
      _(subject.call(factory.env('10.0.0.1', 'firefox'))).must_equal_status 200
    end

    it "allows the request if the user agent hasn't changed" do
      subject.call(factory.env('10.0.0.1', 'firefox'))
      _(subject.call(factory.env('10.0.0.1', 'firefox'))).must_equal_status 200
    end

    it "denies the request if the user agent has changed" do
      subject.call(factory.env('10.0.0.1', 'firefox'))
      _(subject.call(factory.env('10.0.0.1', 'chrome'))).must_equal_status 403
    end

    it "enters the rescue fallback on errors" do
      subject.call(factory.env('10.0.0.1', 'firefox'))
      Rack::Dedos.config[:cache] = :invalid
      _(subject.call(factory.env('10.0.0.1', 'chrome'))).must_equal_status 200
    end

    it "denies the request if already blocked" do
      subject.call(factory.env('10.0.0.1', 'firefox'))
      subject.call(factory.env('10.0.0.1', 'chrome'))
      _(subject.call(factory.env('10.0.0.1', 'chrome'))).must_equal_status 403
    end
  end
end
