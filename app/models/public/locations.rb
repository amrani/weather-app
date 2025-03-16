# frozen_string_literal: true

# Purpose: A public interface for our application to use to call operations for locations.

# Returns: All public methods return a Success or Failure Monad.

# Examples:
#   result = Public::Locations.new.fetch(address: "500 David J Stern Walk Sacramento, CA 95814")
#   # =>  Success(#<Public::Location name="Sacramento" latitude=38.58014045 longitude=-121.49950076409176 zip="95814">)
#
#   result = Public::Locations.new.fetch(address: "Invalid address")
#   # => Failure("Failed to find location")

module Public
  class Locations
    include Dry::Monads[:result]
    extend Dry::Initializer[undefined: false]

    def fetch(address:)
      location = NominatimGeocoder.new(address).call.success
      location = LocalGeocoder.new(address).call.success if location.nil?

      location.present? ? Success(location) : Failure("Failed to find location")
    end
  end
end
