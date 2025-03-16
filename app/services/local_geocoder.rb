# frozen_string_literal: true

# Purpose: Takes in a US zip code and lookups it's latitude and longitude from a
#          local json file that stores all US zipcodes.

# Examples:
#   result = LocalGeocoder.new("2600 Hollywood Boulevard Hollywood, FL 33020-4807").call.success?
#   # => true
#
#   result = LocalGeocoder.new("not an address").call.failure?
#   # => true
#
#   result = LocalGeocoder.new("500 David J Stern Walk Sacramento, CA 95814").call
#   # => Success(#<Public::Location name="Sacramento" latitude=38.5804 longitude=-121.4922 zip="95814">)

class LocalGeocoder
  include Dry::Monads[:result]
  extend Dry::Initializer[undefined: false]

  # A free form string for any USA address. The address must contain a ZIP.
  param :address

  def call
    record = zip_codes[zip]
    return Failure("Failed to geocode") if record.blank?

    # Returns a Success Monad containing a Public::Location
    Success(
      Public::Location.new(
        name: record["city"],
        latitude: record["latitude"],
        longitude: record["longitude"],
        zip: zip
      )
    )
  end

  private

    # Memoize an extracted a zip code from the address
    def zip
      return @zip if defined?(@zip)

      @zip = Formatters::AddressToZip.new(address).call.success
    end

    # Zip codes are stored locally in a JSON file. The file is ~8MB.
    # I cached the JSON object for 1.week. The key to each location is the postal code
    # for quick lookup.

    # I wanted a local storage fallback just incase geocoding via another product failed. This can
    # easily be swapped out with a database lookup with more extensive data.

    # Data source: https://download.geonames.org/export/zip/
    def zip_codes
      Rails.cache.fetch("zip_codes", expires_in: 1.week) do
        JSON.parse(File.read(Rails.root.join("lib", "data", "zipcodes.json")))
      end
    end
end
