# frozen_string_literal: true

# Purpose: A data object representing a specific location.

module Public
  class Location < Dry::Struct
    attribute :name, Types::Strict::String
    attribute :latitude, Types::Coercible::Float
    attribute :longitude, Types::Coercible::Float
    attribute :zip, Types::Coercible::String.optional
  end
end
