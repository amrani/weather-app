# frozen_string_literal: true

# Purpose: A data object representing a forecast for a specific day.

module Public
  class DailyForecast < Dry::Struct
    attribute :date, Types::Params::Date
    attribute :temperature_low, Types::Coercible::Integer
    attribute :temperature_high, Types::Coercible::Integer
  end
end
