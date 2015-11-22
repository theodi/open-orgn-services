module Reports
  class Transaction
    attr_reader :transactions

    def initialize(transactions)
      @transactions = transactions
    end

    def coupons
      transactions.select do |transaction|
        transaction.type == "Adjustment"
      end
    end

    def payments
      transactions.select do |transaction|
        transaction.type == "Payment"
      end
    end

    # We assume that all transactions have the same product_id, this would seem
    # to make sense but we do not control it as they come from Chargify
    def product_id
      transactions.first.product_id
    end

    def payments_total
      payments.reduce(0) { |total, payment| payment.amount_in_cents }
    end

    def coupons_total
      coupons.reduce(0) { |total, coupon| coupon.amount_in_cents.abs }
    end

    # There should never be a payment present if there is a 100% coupon
    # present. There should always be a payment present if there is a non-100%
    # coupon present.
    #
    # So, you can have a 100% coupon on it's own, but any other coupon should
    # have a matching payment.
    def net_total
      if payments_total.zero?
        0
      else
        payments_total - coupons_total
      end
    end

    def key
      if coupon?
        coupons.first.memo.match(/Coupon: (.*) - /)[1]
      else
        "NO COUPON"
      end
    end

    def coupon?
      !coupons.empty?
    end
  end
end

