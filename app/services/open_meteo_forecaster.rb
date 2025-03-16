# frozen_string_literal: true

# Purpose: Takes in a location and send it's latitude and longitude to open meteo's API to
#          fetch the location's forecast.

# Examples:
#   result = OpenMeteoForecaster.new(Public::Location.new(name: "Sacramento", latitude: 38.5804, longitude: -121.4922, zip: "95814")).call.success?
#   # => true
#
#   result = OpenMeteoForecaster.new(nil).call.failure?
#   # => true
#
#   result = OpenMeteoForecaster.new(Public::Location.new(name: "Sacramento", latitude: 38.5804, longitude: -121.4922, zip: "95814")).call
#   # => Success(#<Public::Forecast location=#<Public::Location name="Sacramento" latitude=38.5804 longitude=-121.4922 zip="95814"> forecasted_at=Sun, 16 Mar 2025 16:01:57...

require "net/http"

class OpenMeteoForecaster
  include Dry::Monads[:result]
  extend Dry::Initializer[undefined: false]

  # A Public::Location is required which contains the latitude and longitude
  param :location, type: ::Public::Location

  # API Documentation: https://open-meteo.com/en/docs
  API_URL        = "https://api.open-meteo.com/v1/forecast".freeze
  DEFAULT_PARAMS = {
    current: "temperature_2m",
    hourly: "temperature_2m",
    daily: [ "temperature_2m_max", "temperature_2m_min" ],
    timezone: "auto"
  }.freeze

  def call
    # Return a failure monad if no location is provided.
    return Failure("Location is required") if location.nil?

    # Build the API request with the default's and the location's position.
    query_string = URI.encode_www_form(DEFAULT_PARAMS.merge(latitude: location.latitude, longitude: location.longitude))
    url          = URI("#{API_URL}?#{query_string}")

    # Make the request
    response = Net::HTTP.get_response(url)

    # Check if the request was successful
    if response.code == "200"

      # Parse the JSON response and build the Public::Forecast
      data   = JSON.parse(response.body)
      result = ::Public::Forecast.new(
        location: location,
        forecasted_at: Time.current,
        temperature: temperature_in_f(c: data.dig("current", "temperature_2m")),
        upcoming_hours: upcoming_hours(data: data),
        upcoming_days: upcoming_days(data: data),
      )

      # Return a Success Monad
      Success(result)
    else
      Failure("Failed to load forecast")
    end
  end

  private

    # The external API returns temperatures in Celsius but our public interface expects all temperatures in Fahrenheit
    def temperature_in_f(c:)
      begin
        ((1.8 * c) + 32).round
      rescue
        nil
      end
    end

    # Parse the hourly forceast returned by open-meteo and build an array of Public::HourlyForecast's
    def upcoming_hours(data:)
      # Determine the time of the forecast so we can use it to detemine the upcoming hours
      current_time = Time.parse(data["current"]["time"])

      # Start our index runner at 0
      time_index   = 0

      # Run through each hour in the api response
      data["hourly"]["time"].each_with_index do |time_str, index|

        # Convert the time string into a Time object
        time = Time.parse(time_str)

        # Extract day and hour for comparison
        if time.day == current_time.day && time.hour == current_time.hour

          # Found the current hour
          time_index = index
          break
        end
      end

      # Exclude past hours on only keep the up to 10 times and their respected temperature's.
      times = data["hourly"]["time"][time_index..(time_index + 10)]
      temps = data["hourly"]["temperature_2m"][time_index..(time_index + 10)]

      # Map these times and temps into our Public::HourlyForecast interface
      times&.each_with_index.map do |time, index|
        ::Public::HourlyForecast.new(
          time: Time.parse(time),
          temperature: temperature_in_f(c: temps[index])
        )
      end
    end

    # Parse the day forceast returned by open-meteo and build an array of Public::DailyForecast's
    def upcoming_days(data:)
      # Map the 7-day forecast
      data["daily"]["time"].each_with_index.map do |date, index|
        ::Public::DailyForecast.new(
          date: Date.parse(date),
          temperature_low: temperature_in_f(c: data["daily"]["temperature_2m_min"][index]),
          temperature_high: temperature_in_f(c: data["daily"]["temperature_2m_max"][index]),
        )
      end
    end
end
