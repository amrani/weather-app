# frozen_string_literal: true

# Purpose: Takes in an address and sends it to nominatim openstreetmap's API to
#          geocode it.

# Examples:
#   result = NominatimGeocoder.new("2600 Hollywood Boulevard Hollywood, FL 33020-4807").call.success?
#   # => true
#
#   result = NominatimGeocoder.new("not an address").call.failure?
#   # => true
#
#   result = NominatimGeocoder.new("500 David J Stern Walk Sacramento, CA 95814").call
#   # => Success(#<Public::Location name="Sacramento" latitude=38.58014045 longitude=-121.49950076409176 zip="95814">)

require "net/http"

class NominatimGeocoder
  include Dry::Monads[:result]
  extend Dry::Initializer[undefined: false]

  # A free form string for any address world wide.
  param :address

  # API Documentation: https://nominatim.org/release-docs/develop/api/Search/
  API_URL        = "https://nominatim.openstreetmap.org/search".freeze
  DEFAULT_PARAMS = {
    format: "json",
    limit: "1",
    addressdetails: "1"
  }.freeze

  def call
    # Build the query
    query_string  = URI.encode_www_form(DEFAULT_PARAMS.merge(q: address))
    url           = URI("#{API_URL}?#{query_string}")

    # Make the API request
    response      = Net::HTTP.get_response(url)
    response_body = JSON.parse(response.body)&.first

    # If we have successfully found a location then return a successful monad of a Public::Location
    if response.code == "200" && response_body.present?
      Success(Public::Location.new(
        name: name_from_response(response_body),
        latitude: response_body["lat"],
        longitude: response_body["lon"],
        zip: response_body.dig("address", "postcode").presence || zip_from_address
      ))
    else
      Failure("Could not geocode")
    end
  end

  private

    # The title of the location will first look for city name. If that isn't there, we will try other fields.
    def name_from_response(response_body)
      response_body.dig("address", "city").presence ||
        response_body["name"].presence ||
        response_body["display_name"].presence
    end

    # If the address represents a location containing multiple ZIP codes then the
    # the geocoder will not return a postal code. However, the user may have entered a zip like: "Hollywood, FL 33021".
    #
    # I decided to attempt to extract the zip code from the address so we can cache the location by zip.
    # It isn't perfect but I believe the tradeoff is worth it.
    def zip_from_address
      Formatters::AddressToZip.new(address).call.success
    end
end
