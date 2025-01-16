# frozen_string_literal: true

require_relative '../../../../spec_helper'

describe Rack::Dedos::Executables::Geoipget::Maxmind do
  subject do
    Rack::Dedos::Executables::Geoipget::Maxmind.new(nil, nil, 'linux_amd64')
  end

  describe :latest_version do
    it "fetches the latest version from GitHub" do
      _(subject.send(:latest_version)).must_match(/\d+\.\d+\.\d+/)
    end
  end

  describe :prepare do
    it "downloads the geoipupdate utility" do
      subject.send(:prepare, subject.send(:latest_version)) do
        _('geoipupdate').path_must_exist
      end
    end
  end
end
