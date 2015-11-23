require_relative "report"
require_relative "transaction"
require_relative "row"

module Reports
  class BookingValueReport < Report
    attr_reader :transactions

    def headers
      [
        'product name',
        'booking value',
        'signup count',
        'net',
        'tax',
        'total'
      ]
    end

    def data
      table = []
      table << headers

      customer_transactions_by_product.each do |product_id, groups|
        product = @products.fetch(product_id) do
          raise KeyError, "Product #{product_id} not found"
        end

        groups.each do |coupon_code, transactions|
          table << Row.new(product, coupon_code, transactions).row
        end
      end

      table
    end

    def customer_transactions_by_product
      transactions_by_customer.group_by(&:product_id).each_with_object({}) do |group, hash|
        product_id, transactions = group
        hash[product_id] = transactions.group_by(&:key)
      end
    end

    def transactions_by_customer
      signup_transactions.keys.map do |customer_id|
        Transaction.new(
          customer_transactions[customer_id]
        )
      end
    end

    # Payments and Coupons represent **actual** signups
    def signup_transactions
      @signup_transactions ||= (payments + coupons).group_by(&:customer_id)
    end

    def customer_transactions
      @customer_transactions ||= (payments + coupons + tax_charges).group_by(&:customer_id)
    end

    def payments
      transactions.select do |transaction|
        transaction.type == "Payment" && transaction.memo =~ /Signup payment/
      end
    end

    def tax_charges
      transactions.select do |transaction|
        transaction.type == "Charge" && transaction.kind == "tax"
      end
    end

    def coupons
      transactions.select do |transaction|
        transaction.type == "Adjustment" && transaction.kind == "coupon"
      end
    end
  end
end

