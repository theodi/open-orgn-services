# encoding: utf-8

require "bigdecimal"
require_relative "../../lib/chargify/product_row"

describe Reports::ProductRow do

  let(:product_group) { "" }

  let(:subscriptions) do
    [
      double("Subscription",
        net_total: BigDecimal.new("10.00"),
        tax_total: BigDecimal.new("1.23"),
        total:     BigDecimal.new("11.23")
      ),
      double("Subscription",
        net_total: BigDecimal.new("10.00"),
        tax_total: BigDecimal.new("2.37"),
        total:     BigDecimal.new("12.37")
      )
    ]
  end

  subject do
    Reports::ProductRow.new(product_group, subscriptions)
  end

  describe "#count" do
    it "returns the amount of subscriptions" do
      expect(subject.count).to eq(2)
    end
  end

  describe "#product_price" do
    it "returns the product price" do
      expect(subject.product_price.to_s('F')).to eq("10.0")
    end
  end

  describe "#net_total" do
    it "returns the total of all subscriptions" do
      expect(subject.net_total.to_s('F')).to eq("20.0")
    end
  end

  describe "#tax_total" do
    it "returns the total of all tax charges" do
      expect(subject.tax_total.to_s('F')).to eq("3.6")
    end
  end

  describe "#total" do
    it "returns the total" do
      expect(subject.total.to_s('F')).to eq("23.6")
    end
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

  describe "#row" do
    let(:product_group) do
      "supporter-individual NO COUPON"
    end

    it "returns a row" do
      expect(subject.row).to eq([
        "supporter-individual NO COUPON",
        "10.00",
        2,
        "20.00",
        "3.60",
        "23.60"
      ])
    end
  end
end

