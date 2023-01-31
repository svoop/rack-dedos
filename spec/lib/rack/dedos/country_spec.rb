# frozen_string_literal: true

require_relative '../../../spec_helper'

# We're using the upstream test database included as a git submodule in
# order to avoid license issues. For the contents of the test database see
# https://github.com/maxmind/MaxMind-DB/blob/main/source-data/GeoIP2-Country-Test.json
describe Rack::Dedos::Country do
  before do
    Rack::Dedos.config.clear
    $warning_counter = 0
  end

  let :maxmind_dir do
    File.expand_path(File.dirname(__FILE__) + '../../../../maxmind_db')
  end

  describe :initialize do
    subject do
      Rack::Dedos::Country.new(factory.app,
        maxmind_db_file: maxmind_db_file,
        allowed_countries: %i(CH AT)
      )
    end

    context "broken MaxMind database" do
      let :maxmind_db_file do
        (maxmind_dir + '/bad-data/libmaxminddb/libmaxminddb-offset-integer-overflow.mmdb').tap do |file|
          fail "MaxMind database file not found - you have to update all git submodules" unless File.exist?(file)
        end
      end

      it "fails to initialize" do
        _{ subject }.must_raise StandardError
      end
    end

    context "missing MaxMind database" do
      let :maxmind_db_file do
        '/tmp'
      end

      it "fails to initialize" do
        _{ subject }.must_raise StandardError
      end
    end
  end

  describe :allowed? do
    let :maxmind_db_file do
      (maxmind_dir + '/test-data/GeoLite2-Country-Test.mmdb').tap do |file|
        fail "MaxMind database file not found - you have to update all git submodules" unless File.exist?(file)
      end
    end

    let :ips do
      {
        CH: '2a02:d000::',
        DE: '2a02:d180::',
        AT: '2a02:da80::',
        RU: '2a02:d0c0::',
        local: '::1'
      }
    end

    context "allowed_countries set" do
      subject do
        Rack::Dedos::Country.new(factory.app,
          maxmind_db_file: maxmind_db_file,
          allowed_countries: %i(CH AT)
        )
      end

      it "enters the rescue fallback on errors" do
        Rack::Dedos.config[:maxmind_db] = :invalid
        _(subject.call(factory.env(ips[:DE]))).must_equal_status 200
      end

      it "doesn't enter the rescue fallback otherwise" do
        subject.call(factory.env(ips[:CH]))
        _($warning_counter).must_be :zero?
      end

      it "allows requests from countries on the allowed list" do
        _(subject.call(factory.env(ips[:CH]))).must_equal_status 200
      end

      it "denies requests from countries not on the allowed list" do
        _(subject.call(factory.env(ips[:DE]))).must_equal_status 403
      end

      it "allowes requests which cannot be resolved" do
        _(subject.call(factory.env(ips[:local]))).must_equal_status 200
      end
    end

    context "denied_countries set" do
      subject do
        Rack::Dedos::Country.new(factory.app,
          maxmind_db_file: maxmind_db_file,
          denied_countries: %i(RU)
        )
      end

      it "enters the rescue fallback on errors" do
        Rack::Dedos.config[:maxmind_db] = :invalid
        _(subject.call(factory.env(ips[:RU]))).must_equal_status 200
      end

      it "doesn't enter the rescue fallback otherwise" do
        subject.call(factory.env(ips[:CH]))
        _($warning_counter).must_be :zero?
      end

      it "allows requests from countries not on the denied list" do
        _(subject.call(factory.env(ips[:CH]))).must_equal_status 200
      end

      it "denies requests from countries on the denied list" do
        _(subject.call(factory.env(ips[:RU]))).must_equal_status 403
      end

      it "allowes requests which cannot be resolved" do
        _(subject.call(factory.env(ips[:local]))).must_equal_status 200
      end
    end

    context "both allowed_countries and denied_countries set" do
      subject do
        Rack::Dedos::Country.new(factory.app,
          maxmind_db_file: maxmind_db_file,
          allowed_countries: %i(CH AT),
          denied_countries: %i(RU AT)
        )
      end

      it "enters the rescue fallback on errors" do
        Rack::Dedos.config[:maxmind_db] = :invalid
        _(subject.call(factory.env(ips[:RU]))).must_equal_status 200
      end

      it "doesn't enter the rescue fallback otherwise" do
        subject.call(factory.env(ips[:AT]))
        _($warning_counter).must_be :zero?
      end

      it "gives precedence to the allowed countries list" do
        _(subject.call(factory.env(ips[:AT]))).must_equal_status 200
      end
    end
  end
end
