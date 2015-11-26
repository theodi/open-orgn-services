# encoding: utf-8

require "bigdecimal"
require_relative "../../lib/chargify/product_row"

describe Reports::ProductRow do

  let(:product_group) { "" }

  let(:subscriptions) do
    [
      double("Subscription", net_total: BigDecimal.new("10.00")),
      double("Subscription", net_total: BigDecimal.new("10.00"))
    ]
  end

  subject do
    Reports::ProductRow.new(product_group, subscriptions)
  end

  describe "#booking_value" do

    context "product is paid annually" do
      let(:product_group) do
        "supporter-individual NO COUPON"
      end

      it "returns price divided by signups" do
        expect(subject.booking_value.to_s('F')).to eq("10.0")
      end
    end

    context "product is paid monthly" do
      let(:product_group) do
        "supporter_monthly ODISTARTUP"
      end

      it "returns the price x 12" do
        expect(subject.booking_value.to_s('F')).to eq("120.0")
      end
    end
  end
end

