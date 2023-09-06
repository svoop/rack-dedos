# frozen_string_literal: true

require_relative "lib/rack/dedos/version"

Gem::Specification.new do |spec|
  spec.name        = "rack-dedos"
  spec.version     = Rack::Dedos::VERSION
  spec.summary     = 'Radical filters to block denial-of-service (DoS) requests.'
  spec.description = <<~END
    Somewhat more radical filters designed to decimate malicious requests during
    a denial-of-service (DoS) attack by chopping their connection well before
    your Rack app wastes any significant resources on them – ouch!

    The filters have been proven to work against certain DoS attacks, however,
    they might also block IPs behind proxies or VPNs. Make sure you have
    understood how the filters are triggered and consider this middleware a last
    resort only to be enabled during an attack.
  END
  spec.authors  = ["Sven Schwyn"]
  spec.email    = ["ruby@bitcetera.com"]
  spec.homepage = 'https://github.com/svoop/rack-dedos'
  spec.license  = 'MIT'

  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    'changelog_uri'     => 'https://github.com/svoop/rack-dedos/blob/main/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/svoop/rack-dedos',
    'documentation_uri' => 'https://www.rubydoc.info/gems/rack-dedos',
    'bug_tracker_uri'   => 'https://github.com/svoop/rack-dedos/issues'
  }

  spec.files         = Dir['lib/**/*']
  spec.require_paths = %w(lib)

  spec.cert_chain  = ["certs/svoop.pem"]
  spec.signing_key = File.expand_path(ENV['GEM_SIGNING_KEY']) if ENV['GEM_SIGNING_KEY']

  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.rdoc_options    += [
    '--title', 'AIXM/OFMX Builder',
    '--main', 'README.md',
    '--line-numbers',
    '--inline-source',
    '--quiet'
  ]

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_runtime_dependency 'rack', '>= 2.2.0'

  spec.add_development_dependency 'redis'
  spec.add_development_dependency 'maxmind-db'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-flash'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'yard'
end
