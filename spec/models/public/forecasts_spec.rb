# frozen_string_literal: true

require "rails_helper"

describe Public::Forecasts do
  describe "#fetch" do
    subject(:fetch) { described_class.new.fetch(location: location) }

    context "without location" do
      let(:location) { nil }

      it "fails" do
        expect(fetch.failure?).to eq(true)
      end

      it "returns a failure message" do
        expect(fetch.failure).to eq("Location is required")
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

      it "caches forecast" do
        allow(Rails.cache).to receive(:write)

        fetch

        expect(Rails.cache).to have_received(:write).once.with("33021-forecast", anything, expires_in: 30.minutes)
      end
    end
  end
end
