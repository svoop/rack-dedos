# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Rack::Dedos::Base do
  module Forbidden
    def allowed?(*)
      false
    end
  end

  subject do
    Rack::Dedos::Base.include Forbidden
  end

  describe :call do
    it "responds with status 403 by default" do
      _(subject.new(factory.app).call(factory.env('10.0.0.1'))).must_equal_status 403
    end

    it "responds with generic body by default" do
      _(subject.new(factory.app).call(factory.env('10.0.0.1'))).must_equal_text "Forbidden (Temporarily Blocked by Rules)"
    end

    it "respons with custom status" do
      _(subject.new(factory.app, status: 503).call(factory.env('10.0.0.1'))).must_equal_status 503
    end

    it "responds with generic body by default" do
      _(subject.new(factory.app, text: "Bugger off").call(factory.env('10.0.0.1'))).must_equal_text "Bugger off"
    end
  end
end
