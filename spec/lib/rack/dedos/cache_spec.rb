# frozen_string_literal: true

require_relative '../../../spec_helper'

require 'securerandom'

describe Rack::Dedos::Cache do
  subject do
    Rack::Dedos::Cache
  end

  it "fails for unsupported backends" do
    _{ subject.new(url: 'unsupported://') }.must_raise ArgumentError
  end

  context 'Hash' do
    subject do
      Rack::Dedos::Cache.new(url: 'hash', expires_in: 1)
    end

    describe :store do
      it "returns an instance of Hash" do
        _(subject.store).must_be_instance_of ::Hash
      end
    end

    describe :set, :get do
      let :key do
        SecureRandom.hex
      end

      let :val do
        SecureRandom.hex
      end

      it "sets a value and forgets it after expiration" do
        subject.set(key, val)
        _(subject.get(key)).must_equal val
        sleep 2
        _(subject.get(key)).must_be :nil?
      end

      it "overwrites existing keys" do
        subject.set(key, val)
        _(subject.get(key)).must_equal val
        subject.set(key, key)
        _(subject.get(key)).must_equal key
      end
    end
  end

  context 'Redis' do
    let :key do
      SecureRandom.hex
    end

    let :val do
      SecureRandom.hex
    end

    context "no key prefix set" do
      subject do
        Rack::Dedos::Cache.new(url: 'redis://localhost:6379/12', expires_in: 1)
      end

      describe :store do
        it "returns an instance of Redis" do
          _(subject.store).must_be_instance_of ::Redis
        end
      end

      describe :set, :get do
        it "sets a value and forgets it after expiration" do
          subject.set(key, val)
          _(subject.get(key)).must_equal val
          sleep 2
          _(subject.get(key)).must_be :nil?
        end

        it "overwrites existing keys" do
          subject.set(key, val)
          _(subject.get(key)).must_equal val
          subject.set(key, key)
          _(subject.get(key)).must_equal key
        end
      end
    end

    context "key prefix set" do
      subject do
        Rack::Dedos::Cache.new(url: 'redis://localhost:6379/12', expires_in: 1, key_prefix: 'dedos')
      end

      describe :set, :get do
        it "sets a value using the key prefix" do
          subject.set(key, val)
          _(subject.get(key)).must_equal val
          _(subject.store.get("dedos:#{key}")).must_equal val
        end
      end
    end
  end
end
