# Weather App

A rails application that takes a user provided address and forecasts the weather for that location.

## Installation

```bash
# Clone the repository
git clone https://github.com/amrani/weather-app.git

# Install dependencies
bundle install

# Optional (enable local cache)
rails dev:cache

# Start the server
rails s
```

## Storage

This application does not have an installed database. However, it does have a JSON file of US zipcodes from [geonames](https://download.geonames.org/export/zip/). It also utilizes `Rails.cache`.

## Live Demo

A [live demo]() deployed using heroku.

## Object Decomposition

![object_decompisiton](/doc/images/decompisiton.png)

### Type System

The application uses Dry::Types for type safety:

- **Strict Types**: Ensures all attributes have the correct data type
- **Schema Validation**: Validates nested data structures
- **Type Coercion**: Automatically converts compatible types (e.g., string to integer)

This type system prevents many runtime errors by catching type mismatches at object initialization time.

## Testing

The application uses rspec. You can run the test suite with: `bundle exec rspec spec`
