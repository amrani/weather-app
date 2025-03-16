# frozen_string_literal: true

require "rails_helper"

describe NominatimGeocoder do
  describe "#call" do
    subject(:geocode) { described_class.new(address, zip: zip).call }

    let(:zip) { nil }

    context "when the service fails" do
      let(:address) { "Hollywood, FL 33021" }
      let(:zip) { "33021" }

      before do
        allow(Net::HTTP).to receive(:get_response).and_return(
          instance_double(
            Net::HTTPResponse,
            code: "400",
            body: "{\"error\":{\"code\":400,\"message\":\"Bad Request.\"}}",
            message: "Bad Request"
          )
        )
      end

      it "fails" do
        expect(geocode.success?).to eq(false)
      end

      it "returns error message" do
        expect(geocode.failure).to eq("Could not geocode")
      end
    end

    context "when city zip", vcr: { cassette_name: "services/nominatim_geocoder/city-zip" } do
      let(:address) { "Pembroke Pines 33028" }
      let(:zip) { "33028" }

      it "succeeds" do
        expect(geocode.success?).to eq(true)
      end

      it "works" do
        expect(geocode.success.name).to eq("Pembroke Pines")
        expect(geocode.success.latitude).to eq(26.0061943)
        expect(geocode.success.longitude).to eq(-80.2872086)
        expect(geocode.success.zip).to eq("33028")
      end
    end

    context "when a place", vcr: { cassette_name: "services/nominatim_geocoder/place" } do
      let(:address) { "Museum of Discovery and Science" }

      it "succeeds" do
        expect(geocode.success?).to eq(true)
      end

      it "uses city name" do
        expect(geocode.success.name).to eq("Fort Lauderdale")
        expect(geocode.success.latitude).to eq(26.12110825)
        expect(geocode.success.longitude).to eq(-80.14793230681919)
        expect(geocode.success.zip).to eq("33312")
      end
    end
  end
end
