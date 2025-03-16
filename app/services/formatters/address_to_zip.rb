# frozen_string_literal: true

# Purpose: Extracts a zip code from an address string

class Formatters::AddressToZip
  include Dry::Monads[:result]
  extend Dry::Initializer[undefined: false]

  param :address

  def call
    # Require an address
    return Failure("Address is required") unless address

    # Match the 5-digit part of a ZIP code, whether it's alone or followed by +4
    zip_pattern = /\b(\d{5})(?:-\d{4})?\b/

    # Find all matches in the address string
    matches = address.scan(zip_pattern)

    # Return the last matched 5-digit zip code or nil if no matches found
    matches.empty? ? Success(nil) : Success(matches.last[0])
  end
end
