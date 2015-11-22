# encoding: utf-8

require_relative "../../lib/chargify/booking_value_report"

describe Reports::BookingValueReport do

  let(:customers) {}
  let(:products) do
    {
      3661561 => double("Product", id: "3661561", handle: "individual-supporter", price_in_cents: 9000),
      3660202 => double("Product", id: "3660202", handle: "supporter_annual", price_in_cents: 72000),
      3660323 => double("Product", id: "3660323", handle: "corporate-supporter_legacy_annual", price_in_cents: 220000),
      3661534 => double("Product", id: "3661534", handle: "supporter_monthly", price_in_cents: 6000),
      3660319 => double("Product", id: "3660319", handle: "supporter_legacy_annual", price_in_cents: 0), #???
      3661562 => double("Product", id: "3661562", handle: "holding-individual-supporter", price_in_cents: 0), #???
      3708026 => double("Product", id: "3708026", handle: "individual-supporter-student", price_in_cents: 0), #???
    }
  end

  let(:transactions) do
    @transactions = []
    File.foreach('./spec/reports/transaction.fixtures').with_index do |line, line_number|
      @transactions << OpenStruct.new(eval(line))
    end
    @transactions
  end

  subject do
    Reports::BookingValueReport.new(transactions, customers, products)
  end

  it "loads all the transaction fixtures" do
    expect(transactions.size).to eq(189)
  end

  it "returns signup payments" do
    expect(subject.payments.size).to eq(7)
  end

  it "returns all the coupons" do
    expect(subject.coupons.size).to eq(5)
  end

  it "returns the data" do
    expect(subject.data).to include(["product name",                      "booking value", "signup count", "net",      "tax",      "total"])
    expect(subject.data).to include(["individual-supporter NO COUPON",    90,              3,              "288.00",   "57.60",    "345.60"])
    expect(subject.data).to include(["individual-supporter MENTOR",       90,              3,              "0.00",     "0.00",     "0.00"])
    expect(subject.data).to include(["supporter_annual NO COUPON",        720,             2,              "1584.00",  "316.80",   "1900.80"])
    expect(subject.data).to include(["supporter_annual SUMMIT2015",       720,             1,              "610.00",   "122.00",   "732.00"])
    expect(subject.data).to include(["supporter_legacy_annual NO COUPON", 0,               1,              "540.00",   "108.00",   "648.00"])
    expect(subject.data).to include(["supporter_monthly ODISTARTUP",      720,             1,              "0.00",     "0.00",     "0.00"])
  end
end

