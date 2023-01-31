# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Rack::Dedos do
  it "must be defined" do
    _(Rack::Dedos::VERSION).wont_be_nil
  end
end
