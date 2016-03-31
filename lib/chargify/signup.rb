module Reports
  class Signup
    extend Forwardable

    def_delegators :subscription, :product

    attr_reader :subscription, :tax_charges

    def initialize(subscription, tax_charges)
      @subscription = subscription
      @tax_charges  = tax_charges
    end

    def product_name
      "#{product_handle} #{coupon_code}"
    end

    def signup_revenue
      BigDecimal.new(subscription.signup_revenue)
    end

    def net_total
      signup_revenue - tax_total
    end

    def tax_total
      taxes.reduce(0) do |total, tax|
        total + BigDecimal.new((tax.amount_in_cents.to_f / 100).to_s)
      end
    end

    def total
      net_total + tax_total
    end

    def taxes
      tax_charges.select do |tax_charge|
        tax_charge.customer_id == customer_id
      end
    end

    def coupon_code
      if subscription.coupon_code.nil?
        "NO COUPON"
      else
        subscription.coupon_code
      end
    end

    def customer_id
      subscription.customer.id
    end

    def product_handle
      product.handle
    end
  end
end

