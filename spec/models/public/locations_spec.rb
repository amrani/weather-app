# frozen_string_literal: true

require "rails_helper"

describe Public::Locations do
  include Dry::Monads[:result]

  describe "#fetch" do
    subject(:fetch) { described_class.new.fetch(address: address) }

    context "when nominatim fails" do
      let(:address) { "Hollywood, FL 33021" }
      let(:nominatim_service) { double(call: Failure("Failed")) }

      before do
        allow(NominatimGeocoder).to receive(:new).and_return(nominatim_service)
      end

      it "succeeds" do
        expect(fetch.success?).to eq(true)
      end

      it "returns location" do
        expect(fetch.success.name).to eq("Hollywood")
        expect(fetch.success.latitude).to eq(26.0218)
        expect(fetch.success.longitude).to eq(-80.1891)
        expect(fetch.success.zip).to eq("33021")
      end
    end

    context "when nominatim and local fail" do
      let(:address) { "Hollywood, FL" }
      let(:nominatim_service) { double(call: Failure("Failed")) }

      before do
        allow(NominatimGeocoder).to receive(:new).and_return(nominatim_service)
      end

      it "fails" do
        expect(fetch.failure?).to eq(true)
      end

      it "returns error message" do
        expect(fetch.failure).to eq("Failed to find location")
      end
    end
  end
end
