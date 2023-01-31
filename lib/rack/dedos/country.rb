# frozen_string_literal: true

require 'maxmind/db'

module Rack
  module Dedos
    class Country < Base

      # @option options [String] :maxmind_db_file MaxMind database file
      # @option options [Symbol, Array<Symbol>] :allowed_countries ISO 3166-1 alpha 2
      # @option options [Symbol, Array<Symbol>] :denied_countries ISO 3166-1 alpha 2
      def initialize(*)
        super
        @maxmind_db_file = options[:maxmind_db_file] or fail "MaxMind database file not set"
        @allowed = case
          when @countries = options[:allowed_countries] then true
          when @countries = options[:denied_countries] then false
          else fail "neither allowed nor denied countries set"
        end
        maxmind_db   # hit once to fail on errors at boot
      end

      def allowed?(request)
        if country = maxmind_db.get(request.ip)
          country_code = country.dig('country', 'iso_code').to_sym
          @countries.include?(country_code) ? @allowed : !@allowed
        else   # not found in database
          true
        end
      rescue => error
        warn("rack-dedos: request from #{request.ip} allowed due to error: #{error.message}")
        true
      end

      private

      def maxmind_db
        config[:maxmind_db] ||= MaxMind::DB.new(
          @maxmind_db_file,
          mode: MaxMind::DB::MODE_FILE
        )
      end

    end
  end
end
