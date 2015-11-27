# encoding: utf-8

require_relative "../../lib/chargify/booking_value_report"

describe Reports::BookingValueReport do

  let(:products) { [] }
  let(:customers) { [] }

  let(:subscriptions) do
    [
      double("Subscription", "state" => "active",   "signup_revenue" => "90.00",  "coupon_code"=>nil,          "product_price_in_cents"=>9000,  "customer" => double("Customer", "id" => 10245249), "product" => double("Product", "handle" => "individual-supporter")),
      double("Subscription", "state" => "active",   "signup_revenue" => "0.00",   "coupon_code"=>"ODISTARTUP", "product_price_in_cents"=>6000,  "customer" => double("Customer", "id" => 10243863), "product" => double("Product", "handle" => "supporter_monthly")),
      double("Subscription", "state" => "active",   "signup_revenue" => "90.00",  "coupon_code"=>nil,          "product_price_in_cents"=>9000,  "customer" => double("Customer", "id" => 10228995), "product" => double("Product", "handle" => "individual-supporter")),
      double("Subscription", "state" => "active",   "signup_revenue" => "725.76", "coupon_code"=>"SUMMIT2015", "product_price_in_cents"=>72000, "customer" => double("Customer", "id" => 10213864), "product" => double("Product", "handle" => "supporter_annual")),
      double("Subscription", "state" => "active",   "signup_revenue" => "0.00",   "coupon_code"=>nil,          "product_price_in_cents"=>0,     "customer" => double("Customer", "id" => 10122655), "product" => double("Product", "handle" => "holding-individual-supporter")),
      double("Subscription", "state" => "active",   "signup_revenue" => "0.00",   "coupon_code"=>nil,          "product_price_in_cents"=>0,     "customer" => double("Customer", "id" => 10122644), "product" => double("Product", "handle" => "holding-individual-supporter")),
      double("Subscription", "state" => "active",   "signup_revenue" => "0.00",   "coupon_code"=>"MENTOR",     "product_price_in_cents"=>9000,  "customer" => double("Customer", "id" => 10070902), "product" => double("Product", "handle" => "individual-supporter")),
      double("Subscription", "state" => "active",   "signup_revenue" => "108.00", "coupon_code"=>nil,          "product_price_in_cents"=>9000,  "customer" => double("Customer", "id" => 10041288), "product" => double("Product", "handle" => "individual-supporter")),
      double("Subscription", "state" => "active",   "signup_revenue" => "0.00",   "coupon_code"=>"MENTOR",     "product_price_in_cents"=>9000,  "customer" => double("Customer", "id" => 10027416), "product" => double("Product", "handle" => "individual-supporter")),
      double("Subscription", "state" => "canceled", "signup_revenue" => "0.00",   "coupon_code"=>"MENTOR",     "product_price_in_cents"=>9000,  "customer" => double("Customer", "id" => 10027416), "product" => double("Product", "handle" => "individual-supporter"))
    ]
  end

  let(:transactions) do
    @transactions = []
    File.foreach('./spec/reports/transaction.fixtures').with_index do |line, line_number|
      @transactions << OpenStruct.new(eval(line))
    end
    @transactions
  end

  subject do
    Reports::BookingValueReport.new(transactions, customers, products, subscriptions)
  end

  it "loads all the transaction fixtures" do
    expect(transactions.size).to eq(189)
  end

  describe "#subscriptions" do
    it "only returns active subscriptions" do
      expect(subject.subscriptions.size).to eq(9)
    end
  end

  it "returns the data" do
    expect(subject.data).to include(["product name",                            "booking value",   "signup count", "net",    "tax",    "total"])
    expect(subject.data).to include(["individual-supporter NO COUPON",          "90.00",           3,              "270.00", "18.00",  "288.00"])
    expect(subject.data).to include(["supporter_monthly ODISTARTUP",            "0.00",            1,              "0.00",   "0.00",   "0.00"])
    expect(subject.data).to include(["supporter_annual SUMMIT2015",             "604.80",          1,              "604.80", "120.96", "725.76"])
    expect(subject.data).to include(["holding-individual-supporter NO COUPON",  "0.00",            2,              "0.00",   "0.00",   "0.00"])
    expect(subject.data).to include(["individual-supporter MENTOR",             "0.00",            2,              "0.00",   "0.00",   "0.00"])
  end
end

