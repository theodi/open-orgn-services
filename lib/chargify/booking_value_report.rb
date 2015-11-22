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
      customer_transactions.group_by(&:customer_id).map do |customer_id, transactions|
        Transaction.new(transactions)
      end
    end

    def customer_transactions
      payments + coupons
    end

    def payments
      transactions.select do |transaction|
        transaction.type == "Payment" && transaction.memo =~ /Signup payment/
      end
    end

    def coupons
      transactions.select do |transaction|
        transaction.type == "Adjustment" && transaction.kind == "coupon"
      end
    end
  end
end

