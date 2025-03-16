# frozen_string_literal: true

# Purpose: A public interface for our application to use to call operations for locations.

# Returns: All public methods return a Success or Failure Monad.

# Examples:
#   result = Public::Forecasts.new.fetch(location: Public::Location.new(name: "Sacramento", latitude: 38.5804, longitude: -121.4922, zip: "95814"))
#   # =>  Success(#<Public::Forecast location=#<Public::Location name="Sacramento" latitude=38.5804 longitude=-121.4922 zip="95814"> forecasted_at=Sun, 16 Mar 2025 16:23:15...
#
#   result = Public::Forecasts.new.fetch(location: nil)
#   # => Failure("Location is required")

#   result = Public::Forecasts.new.fetch(location: Public::Location.new(name: "Invalid Location", zip: "ABC", latitude: 404, longitude: 404))
#   # => Failure("Failed to load forecast")

module Public
  class Forecasts
    include Dry::Monads[:result]
    extend Dry::Initializer[undefined: false]

    # Determine a forecast from a location
    def fetch(location:)
      # A location is required
      return Failure("Location is required") if location.blank?

      # Attempt to use the open meteo external API source
      result = ::OpenMeteoForecaster.new(location).call

      if result.success?
        # Cache the response
        cache_forecast(forecast: result.success)

        # Return the Success Monad
        result
      else
        # Return a failure
        Failure("Failed to load forecast")
      end
    end

    # A public method for looking up cached forecasts.
    def fetch_by_cache(zip:)
      cached_result = Rails.cache.fetch("#{zip}-forecast")

      # If a cache hit then return the forecast
      cached_result.present? ? Success(cached_result) : Failure(nil)
    end

    private

      # Store the Public::Forecast in cache with a "[ZIP]-forecast" key that lives for 30 minutes.
      # The stored forecast also contains the location and a forecasted_at timestamp.
      def cache_forecast(forecast:)
        if forecast.location.zip.present?
          Rails.cache.write("#{forecast.location.zip}-forecast", forecast, expires_in: 30.minutes)
        end
      end
  end
end
