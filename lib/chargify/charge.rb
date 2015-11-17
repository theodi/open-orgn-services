require_relative "charge_row"

module Reports
  class Charge
    extend Forwardable

    attr_reader :transactions, :products, :customers

    def initialize(transactions, products, customers)
      @transactions = transactions
      @products     = products
      @customers    = customers
    end

    def to_row
      ChargeRow.new(self).row
    end

    def obj
      (transactions['Payment'] || transactions['Adjustment'] || transactions['Charge']).first
    end

    def adjustment?
      obj.type == 'Adjustment'
    end

    def total
      if adjustment?
        charges_and_adjustments.sum(&:amount_in_cents)
      else
        obj.amount_in_cents
      end
    end

    def net_price
      charges['baseline'].first.amount_in_cents
    end

    def net_after_discount
      net_price - discount.abs
    end

    def tax_amount
      if charges['tax'].present?
        charges['tax'].first.amount_in_cents.to_i
      else
        0
      end
    end

    def charges
      transactions['Charge'].group_by(&:kind)
    end

    def charges_and_adjustments
      transactions.values.flatten.select do |transaction|
        %w[Charge Adjustment].include?(transaction.type)
      end
    end

    def discount
      if adjustment?
        obj.amount_in_cents
      else
        0
      end
    end

    def_delegators :obj, :customer_id, :product_id, :statement_id, :created_at

    def customer
      @customers[customer_id]
    end

    def product
      @products[product_id]
    end

    def company_name
      if customer.organization.present?
        customer.organization
      else
        [customer.first_name, customer.last_name].join(" ")
      end
    end

    def customer_reference
      customer.reference.to_s
    end

    def product_handle
      product.handle
    end

    def coupon_code
      return "" unless adjustment?

      /Coupon: (.+) -/.match(obj.memo)[1]
    end

    def coupon_amount
      return if discount.zero?

      (discount.abs / (net_price / 100))
    end
  end
end

