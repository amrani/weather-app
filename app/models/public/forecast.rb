# frozen_string_literal: true

# Purpose: A data object representing a weather forecast for a specific location.

module Public
  class Forecast < Dry::Struct
    attribute :location, Public::Location
    attribute :forecasted_at, Types::Params::Time
    attribute :temperature, Types::Coercible::Integer
    attribute :upcoming_hours, Types::Array.of(HourlyForecast).optional
    attribute :upcoming_days, Types::Array.of(DailyForecast).optional
  end
end
