require_relative "../../lib/chargify/booking_value_report"

describe Reports::BookingValueReport do

  let(:transactions) do
    [
      double("Transaction", type: 'Payment', product_id: "456"),
      double("Transaction", type: 'Payment', product_id: "456"),
      double("Transaction", type: 'Payment', product_id: "456"),
      double("Transaction", type: 'Payment', product_id: "456"),
      double("Transaction", type: 'Payment', product_id: "456"),

      double("Transaction", type: 'Payment', product_id: "789"),
      double("Transaction", type: 'Payment', product_id: "789"),
      double("Transaction", type: 'Payment', product_id: "789"),

      double("Transaction", type: 'Payment', product_id: "012"),
      double("Transaction", type: 'Payment', product_id: "012"),

      double("Transaction", type: 'Payment', product_id: "345"),
    ]
  end

  let(:customers) {}
  let(:products) do
    {
      "A" => double("Product", id: "456", handle: "individual-supporter", price_in_cents: 9000),
      "B" => double("Product", id: "789", handle: "supporter_annual", price_in_cents: 72000),
      "C" => double("Product", id: "012", handle: "corporate-supporter_annual", price_in_cents: 220000),
      "D" => double("Product", id: "345", handle: "supporter_monthly", price_in_cents: 6000),
    }
  end

  subject do
    Reports::BookingValueReport.new(transactions, customers, products)
  end

  it "returns the data" do
    expect(subject.data).to eq(
      [
        ["product name",               "signup count", "booking value", "net",  "tax", "total"],
        ["individual-supporter",       "5",            "90",            "450",  "90",  "540"],
        ["supporter_annual",           "3",            "720",           "2160", "432", "2592"],
        ["corporate-supporter_annual", "2",            "2200",          "4400", "880", "5280"],
        ["supporter_monthly",          "1",            "720",           "720",  "144", "864"]
      ]
    )
  end
end


