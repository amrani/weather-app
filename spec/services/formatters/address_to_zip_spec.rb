# frozen_string_literal: true

require "rails_helper"

describe Formatters::AddressToZip do
  describe "#call" do
    subject(:format) { described_class.new(address).call }

    context "when address is nil" do
      let(:address) { nil }

      it "fails" do
        expect(format.failure?).to eq(true)
      end

      it "returns error message" do
        expect(format.failure).to eq("Address is required")
      end
    end

    context "when address is blank" do
      let(:address) { "" }

      it "succeeds" do
        expect(format.success?).to eq(true)
      end

      it "returns nil" do
        expect(format.success).to eq(nil)
      end
    end

    context "when no zip present" do
      let(:address) { "Hollywood, FL" }

      it "succeeds" do
        expect(format.success?).to eq(true)
      end

      it "returns nil" do
        expect(format.success).to eq(nil)
      end
    end

    context "when zip+4" do
      let(:address) { "4000 N 12 ave Hollywood, FL 33021-1912" }

      it "works" do
        expect(format.success).to eq("33021")
      end
    end

    context "when the street number contains 5 numbers" do
      let(:address) { "12345 Washington Ave, Dallas, Texas 40001 USA" }

      it "works" do
        expect(format.success).to eq("40001")
      end
    end
  end
end
