# frozen_string_literal: true

require "rails_helper"

describe OpenMeteoForecaster do
  describe "#call" do
    subject(:forecast) { described_class.new(location).call }

    context "without location" do
      let(:location) { nil }

      it "fails" do
        expect(forecast.failure?).to eq(true)
      end

      it "returns a failure message" do
        expect(forecast.failure).to eq("Location is required")
      end
    end

    context "with location", vcr: { cassette_name: "services/open_meteo_forecaster" } do
      let(:location) {
        Public::Location.new(
          name: "Hollywood",
          latitude: 26.0218,
          longitude: -80.1891,
          zip: "33021"
        )
      }

      it "succeeds" do
        expect(forecast.success?).to eq(true)
      end

      it "returns the location" do
        expect(forecast.success.location).to eq(location)
      end

      it "returns temperature" do
        expect(forecast.success.temperature).to eq(75)
      end

      it "returns upcoming_hours" do
        expect(forecast.success.upcoming_hours.pluck(:time, :temperature)).to eq(
          [
            [ DateTime.parse("2025-03-15 21:00:00 -0400"), 75 ],
            [ DateTime.parse("2025-03-15 22:00:00 -0400"), 75 ],
            [ DateTime.parse("2025-03-15 23:00:00 -0400"), 75 ],
            [ DateTime.parse("2025-03-16 00:00:00 -0400"), 74 ],
            [ DateTime.parse("2025-03-16 01:00:00 -0400"), 74 ],
            [ DateTime.parse("2025-03-16 02:00:00 -0400"), 74 ],
            [ DateTime.parse("2025-03-16 03:00:00 -0400"), 74 ],
            [ DateTime.parse("2025-03-16 04:00:00 -0400"), 74 ],
            [ DateTime.parse("2025-03-16 05:00:00 -0400"), 74 ],
            [ DateTime.parse("2025-03-16 06:00:00 -0400"), 74 ],
            [ DateTime.parse("2025-03-16 07:00:00 -0400"), 74 ]
          ]
        )
      end

      it "returns upcoming_days" do
        expect(forecast.success.upcoming_days.pluck(:date, :temperature_low, :temperature_high)).to eq(
          [
            [ Date.parse("Sat, 15 Mar 2025"), 72, 81 ],
            [ Date.parse("Sun, 16 Mar 2025"), 74, 84 ],
            [ Date.parse("Mon, 17 Mar 2025"), 66, 79 ],
            [ Date.parse("Tue, 18 Mar 2025"), 60, 75 ],
            [ Date.parse("Wed, 19 Mar 2025"), 65, 78 ],
            [ Date.parse("Thu, 20 Mar 2025"), 64, 82 ],
            [ Date.parse("Fri, 21 Mar 2025"), 68, 72 ]
          ]
        )
      end
    end
  end
end
