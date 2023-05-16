[![Version](https://img.shields.io/gem/v/rack-dedos.svg?style=flat)](https://rubygems.org/gems/rack-dedos)
[![Tests](https://img.shields.io/github/actions/workflow/status/svoop/rack-dedos/test.yml?style=flat&label=tests)](https://github.com/svoop/rack-dedos/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/svoop/rack-dedos.svg?style=flat)](https://codeclimate.com/github/svoop/rack-dedos/)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

<img src="https://github.com/svoop/rack-dedos/raw/main/doc/chop-chop.png" alt="chop-chop" align="right">

# Rack::Dedos

Somewhat more radical filters designed to decimate malicious requests during a [denial-of-service (DoS) attack](https://en.wikipedia.org/wiki/Denial-of-service_attack) by chopping their connection well before your Rack app wastes any significant resources on them – ouch!

The filters have been proven to work against certain DoS attacks, however, they might also block IPs behind proxies or VPNs. Make sure you have understood how the filters are triggered and consider this middleware a last resort only to be enabled during an attack.

* [Homepage](https://github.com/svoop/rack-dedos)
* [API](https://www.rubydoc.info/gems/rack-dedos)
* Author: [Sven Schwyn - Bitcetera](https://bitcetera.com)

## Install

### Security

This gem is [cryptographically signed](https://guides.rubygems.org/security/#using-gems) in order to assure it hasn't been tampered with. Unless already done, please add the author's public key as a trusted certificate now:

```
gem cert --add <(curl -Ls https://raw.github.com/svoop/rack-dedos/main/certs/svoop.pem)
```

### Bundler

Add the following to the <tt>Gemfile</tt> or <tt>gems.rb</tt> of your [Bundler](https://bundler.io) powered Ruby project:

```ruby
gem 'rack-dedos'
```

And then install the bundle:

```
bundle install --trust-policy MediumSecurity
```

## Configuration

Given the drastic nature of the filters, you should use this middleware for production environments only and/or if an environment variable like `UNDER_ATTACK` is set to true.

### Rails

```ruby
# config/application.rb
class Application < Rails::Application
  if Rails.env.production? && ActiveModel::Type::Boolean.new.cast(ENV['UNDER_ATTACK'])
    config.middleware.use Rack::Dedos
  end
end
```

### Rackup

```ruby
#!/usr/bin/env rackup
require 'rack/dedos'

if %w(true t on 1).include? ENV['UNDER_ATTACK']
  use Rack::Dedos
end

run lambda { |env| [200, {'Content-Type' => 'text/plain'}, "Hello, world!\n"] }
```

### Response

If a request is classified as malicious by at least one filter, the middleware responds with:

> 403 Forbidden (Temporarily Blocked by Rules)

This is the most appropriate response, however, feel free to trick the requester by tweaking this:

```ruby
use Rack::Dedos,
  status: 503,
  text: "Temporary Server Error"
```

## Filters

By default, all filters described below are applied. You can exclude certain filters:

```ruby
use Rack::Dedos,
  except: [:user_agent]
```

To only apply one specific filter, use the corresponding class as shown below.

### User Agent Filter

```ruby
use Rack::Dedos::Filters::UserAgent,
  cache_url: 'redis://redis.example.com:6379/12',   # db 12 on default port
  cache_key_prefix: 'dedos',   # key prefix for shared caches (default: nil)
  cache_period: 1800   # seconds (default: 900)
```

Requests are blocked for `cache_period` seconds in case another request has been made within `cache_period` seconds from by same IP address but with a different user agent.

The following cache backends are supported:

* `redis://...` – ⚠️ The [redis gem](https://rubygems.org/gems/redis) has to be installed.
* `hash` – Only for testing, don't use this in production.

### Country Filter

```ruby
use Rack::Dedos::Filters::Country,
  maxmind_db_file: '/var/db/maxmind/GeoLite2-Country.mmdb',
  allowed_countries: %i(AT CH DE),
  denied_countries: %i(RU)
```

Either allow or deny requests by probable country of origin. If both are set, the `denied_countries` option is ignored.

⚠️ The [maxmind-db gem](https://rubygems.org/gems/maxmind-db) has to be installed.

The MaxMind GeoLite2 database is free, however, you have to create an account on [maxmind.com](https://www.maxmind.com) and then download the country database.

For automatic updates, create a `geoipupdate.conf` file and then use the [geoipupdate tool](https://github.com/maxmind/geoipupdate/releases) to fetch the latest country database:

```
version=4.10.0
arch=linux_amd64
conf=/etc/geoipupdate.conf
dir=/var/db/maxmind/

mkdir -p "${dir}"
wget --quiet -O /tmp/geoipupdate.tgz https://github.com/maxmind/geoipupdate/releases/download/v${version}/geoipupdate_${version}_${arch}.tar.gz
tar -xz -C /tmp -f /tmp/geoipupdate.tgz
/tmp/geoipupdate_${version}_${arch}/geoipupdate -f "${conf}" -d "${dir}"
```

## Real Client IP

A word on how the real client IP is determined. Both Rack 2 and Rack 3 (up to 3.0.7 at the time of writing) may populate the request `ip` incorrectly. Here's what a minimalistic Rack app deloyed to Render (behind Cloudflare) reports:

> request.ip = 172.71.135.17<br>
> request.forwarded_for = ["81.XXX.XXX.XXX", "172.71.135.17", "10.201.229.136"]

Obviously, the reported IP 172.71.135.17 is not the real client IP, the correct one is the (redacted) 81.XXX.XXX.XXX.

Due to this flaw, Rack::Dedos determines the real client IP as follows in order of priority:

1. [`Cf-Connecting-Ip` header](https://developers.cloudflare.com/fundamentals/get-started/reference/http-request-headers/#cf-connecting-ip)
2. First entry of the [`X-Forwarded-For` header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For)
3. [`ip` reported by Rack](https://github.com/rack/rack/blob/main/lib/rack/request.rb)

## Development

For all required test fixtures to be present, you have to check out the repo
with all of its submodules:

```
git clone git@github.com:svoop/rack-dedos.git
cd rack-dedos
git submodule update --init
```

To install the development dependencies and then run the test suite:

```
bundle install
bundle exec rake    # run tests once
bundle exec guard   # run tests whenever files are modified
```

You're welcome to [submit issues](https://github.com/svoop/rack-dedos/issues) and contribute code by [forking the project and submitting pull requests](https://docs.github.com/en/get-started/quickstart/fork-a-repo).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
