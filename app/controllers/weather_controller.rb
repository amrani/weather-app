# frozen_string_literal: true

class WeatherController < ApplicationController
  def show
    current_hour = Time.now.hour
    @theme = current_hour >= 6 && current_hour < 18 ? "day" : "day"

    zip       = Formatters::AddressToZip.new(params[:address]).call.success
    @forecast = Public::Forecasts.new.fetch_by_cache(zip: zip).success

    unless @forecast
      location = Public::Locations.new.fetch(address: params[:address]).success
      @forecast = Public::Forecasts.new.fetch(location: location).success
    end
  end
end
