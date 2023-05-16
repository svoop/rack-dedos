# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Rack::Dedos::Filters::Base do
  module Forbidden
    def allowed?(*)
      false
    end
  end

  subject do
    Rack::Dedos::Filters::Base.include Forbidden
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

  describe :real_ip do
    context 'priority 1' do
      it 'returns the Cf-Connecting-Ip' do
        mock_request = MiniTest::Mock.new
          .expect(:get_header, '1.2.3.4') { _1 == 'HTTP_CF_CONNECTING_IP' }
        _(subject.new(factory.app).send(:real_ip, mock_request)).must_equal '1.2.3.4'
        _(mock_request.verify).must_equal true
      end
    end

    context 'priority 2' do
      it 'returns the first entry of X-Forwarded-For' do
        mock_request = MiniTest::Mock.new
          .expect(:get_header, nil) { _1 == 'HTTP_CF_CONNECTING_IP' }
          .expect(:forwarded_for, '2.3.4.5, 3.4.5.6')
        _(subject.new(factory.app).send(:real_ip, mock_request)).must_equal '2.3.4.5'
        _(mock_request.verify).must_equal true
      end

      it 'returns the only entry of X-Forwarded-For' do
        mock_request = MiniTest::Mock.new
          .expect(:get_header, nil) { _1 == 'HTTP_CF_CONNECTING_IP' }
          .expect(:forwarded_for, '3.4.5.6')
        _(subject.new(factory.app).send(:real_ip, mock_request)).must_equal '3.4.5.6'
        _(mock_request.verify).must_equal true
      end

      it 'removes port numbers which should not be there in the first place' do
        mock_request = MiniTest::Mock.new
          .expect(:get_header, nil) { _1 == 'HTTP_CF_CONNECTING_IP' }
          .expect(:forwarded_for, '4.5.6.7:123')
        _(subject.new(factory.app).send(:real_ip, mock_request)).must_equal '4.5.6.7'
        _(mock_request.verify).must_equal true
      end
    end

    context 'priority 3' do
      it "returns the IP reported by Rack" do
        mock_request = MiniTest::Mock.new
          .expect(:get_header, nil) { _1 == 'HTTP_CF_CONNECTING_IP' }
          .expect(:forwarded_for, nil)
          .expect(:ip, '4.5.6.7')
        _(subject.new(factory.app).send(:real_ip, mock_request)).must_equal '4.5.6.7'
        _(mock_request.verify).must_equal true
      end
    end
  end
end
