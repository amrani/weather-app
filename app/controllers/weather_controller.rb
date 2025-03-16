# frozen_string_literal: true

class WeatherController < ApplicationController
  def show
    # Determine the theme between day or night. I decided to hardcode PT
    # but a nice improvement would be to use the timezone of the location searched.
    current_hour = Time.now.in_time_zone("Pacific Time (US & Canada)").hour
    @theme       = current_hour >= 6 && current_hour < 18 ? "day" : "night"

    # Try to extract a zip code from the address provided.
    zip       = Formatters::AddressToZip.new(params[:address]).call.success

    # Check if the zip code is in the forecast cache
    @forecast = Public::Forecasts.new.fetch_by_cache(zip: zip).success

    # If it is not in the cache then let's fetch the live forecast
    unless @forecast
      # Geocode the location
      location = Public::Locations.new.fetch(address: params[:address]).success

      # Fetch the forecast
      @forecast = Public::Forecasts.new.fetch(location: location).success
    end
  end
end
