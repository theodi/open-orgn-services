require_relative "../../lib/chargify/transaction"

describe Reports::Transaction do

  let(:payment) do
    double("Payment",
      type: "Payment",
      product_id: 123,
      amount_in_cents: 9000
    )
  end

  let(:coupon) do
    double("Coupon",
      type: "Adjustment",
      product_id: 456,
      amount_in_cents: -9000,
      ending_balance_in_cents: 0,
      memo: "Coupon: MENTOR - 100% off"
    )
  end

  let(:fifty_percent_coupon) do
    double("Coupon",
      type: "Adjustment",
      product_id: 456,
      amount_in_cents: -4500,
      ending_balance_in_cents: 4500,
      memo: "Coupon: FIFTY - 50% off"
    )
  end


  let(:vat_charge) do
    double("VAT",
      type: "Charge",
      amount_in_cents: 1200
    )
  end

  let(:transactions) do
    [payment, coupon, vat_charge]
  end

  subject do
    Reports::Transaction.new(transactions)
  end

  describe "#coupons" do
    it "should return coupon transactions" do
      expect(subject.coupons).to include(coupon)
      expect(subject.coupons).to_not include(payment)
      expect(subject.coupons).to_not include(vat_charge)
    end
  end

  describe "#payments" do
    it "should return payment transactions" do
      expect(subject.payments).to include(payment)
      expect(subject.payments).to_not include(coupon)
      expect(subject.payments).to_not include(vat_charge)
    end
  end

  describe "#taxes" do
    it "should return tax (charge) transactions" do
      expect(subject.taxes).to include(vat_charge)
      expect(subject.taxes).to_not include(payment)
      expect(subject.taxes).to_not include(coupon)
    end
  end

  describe "#product_id" do
    it "returns the first transaction's product id" do
      expect(subject.product_id).to eq(123)
    end
  end

  describe "#payments_total" do
    it "sums all payments" do
      expect(subject.payments_total).to eq(9000)
    end
  end

  describe "#coupons_total" do
    it "sums all coupons" do
      expect(subject.coupons_total).to eq(9000)
    end
  end

  describe "#taxes_total" do
    it "sums all taxes" do
      expect(subject.taxes_total).to eq(1200)
    end
  end

  describe "#net_total" do
    context "payment only" do
      let(:transactions) do
        [payment]
      end

      it "returns the total" do
        expect(subject.net_total).to eq(9000)
      end
    end

    context "payment and 50% coupon" do
      let(:transactions) do
        [payment, fifty_percent_coupon]
      end

      it "returns the total" do
        expect(subject.net_total).to eq(4500)
      end
    end

    context "100% coupon" do
      let(:transactions) do
        [coupon]
      end

      it "returns the total" do
        expect(subject.net_total).to eq(0)
      end
    end

    context "payment, 50% coupon and VAT charge" do
      let(:transactions) do
        [payment, fifty_percent_coupon, vat_charge]
      end

      it "returns the total" do
        expect(subject.net_total).to eq(3300)
      end
    end
  end

  describe "#key" do
    context "there are no coupon transactions" do
      let(:transactions) do
        [payment]
      end

      it "should return 'NO COUPON' if there is no associated coupon" do
        expect(subject.key).to eq("NO COUPON")
      end
    end

    context "there are coupon transactions" do
      let(:transactions) do
        [payment, coupon]
      end

      it "should return the coupon name" do
        expect(subject.key).to eq("MENTOR")
      end
    end
  end

  describe "#coupon?" do
    context "there are no coupon transactions" do
      let(:transactions) { [] }

      it "should return false" do
        expect(subject.coupon?).to eq(false)
      end
    end

    context "there are coupon transactions" do
      let(:transactions) { [coupon] }

      it "should return true" do
        expect(subject.coupon?).to eq(true)
      end
    end
  end
end

