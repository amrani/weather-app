# frozen_string_literal: true

# Purpose: A data object representing a forecast at a specifc time.

module Public
  class HourlyForecast < Dry::Struct
    attribute :time, Types::Params::Time
    attribute :temperature, Types::Coercible::Integer
  end
end
