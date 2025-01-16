# frozen_string_literal: true

require 'optparse'
require 'tmpdir'
require 'open-uri'
require 'json'
require 'rubygems/package'

module Rack
  module Dedos
    module Executables
      class Geoipget
        attr_reader :config, :dir, :arch

        def initialize(**options)
          @arch, @dir = 'linux_amd64', '.'
          OptionParser.new do |o|
            o.banner = <<~END
              Download the geoip database from Maxmind.
              Usage: #{::File.basename($0)} CONFIG_FILE
            END
            o.on('-a', '--arch ARCH', String, "architecture (default: #{arch})") { @arch = _1 }
            o.on('-d', '--dir DIR', String, "destination directory (default: #{dir})") { @dir = _1 }
            o.on('-A', '--about', 'show author/license information and exit') { self.class.about }
            o.on('-V', '--version', 'show version and exit') { self.class.version }
          end.parse!
          @config = ARGV.first
        end

        def run
          fail "cannot read config file #{config}" unless config && ::File.readable?(config)
          Maxmind.new(config, ::File.realpath(dir), arch).get
        end

        def self.about
          puts 'Written by Sven Schwyn (bitcetera.com) and distributed under MIT license.'
          exit
        end

        def self.version
          puts Rack::Dedos::VERSION
          exit
        end

        class Maxmind
          REPO = "maxmind/geoipupdate"

          attr_reader :config, :dir, :arch

          def initialize(config, dir, arch)
            @config, @dir, @arch = config, dir, arch
          end

          def get
            prepare(latest_version) { download }
          end

          private

          def latest_version
            URI("https://api.github.com/repos/#{REPO}/releases/latest")
              .read
              .then { JSON.parse(_1) }
              .fetch('tag_name')
              .slice(1..)
          end

          def prepare(version)
            uri = URI("https://github.com/#{REPO}/releases/download/v#{version}/geoipupdate_#{version}_#{arch}.tar.gz")
            Dir.mktmpdir do |tmp|
              Dir.chdir tmp
              uri.open do |file|
                Zlib::GzipReader.wrap(file) do |gz|
                  Gem::Package::TarReader.new(gz) do |tar|
                    tar.each do |entry|
                      if entry.full_name.match? %r(/geoipupdate$)
                        ::File.write('geoipupdate', entry.read)
                      end
                    end
                  end
                end
              end
              ::File.chmod(0755, 'geoipupdate')
              yield
            end
          ensure
            lockfile = "#{dir}/.geoipupdate.lock"
            ::File.unlink(lockfile) if ::File.exist? lockfile
          end

          def download
            `./geoipupdate -f "#{config}" -d "#{dir}"`
          end
        end
      end
    end
  end
end
