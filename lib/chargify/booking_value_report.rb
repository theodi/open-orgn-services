require_relative "report"

module Reports
  class BookingValueReport < Report
    def headers
      [
        'product name',
        'signup count',
        'booking value',
        'net',
        'tax',
        'total'
      ]
    end

    def data
      table = []
      table << headers

      @products.values.each do |product|
        ProductRow.new(@transactions, product).rows.each do |row|
          table << row
        end
      end

      table
    end

    class ProductRow
      attr_reader :transactions, :product

      def initialize(transactions, product)
        @transactions = transactions
        @product = product
      end

      def count
        transactions.count do |transaction|
          transaction.type == 'Payment' && transaction.memo =~ /Signup payment/ && transaction.product_id == product.id
        end
      end

      def amount
        if product.handle =~ /monthly$/
          product.price_in_cents * 12 / 100
        else
          product.price_in_cents / 100
        end
      end

      def net
        amount * count
      end

      def total
        1.2 * net
      end

      def tax
        0.2 * net
      end

      def rows
        [
          row
        ]
      end

      def row
        [
          product.handle,
          count.to_s,
          amount.to_i.to_s,
          net.to_i.to_s,
          tax.to_i.to_s,
          total.to_i.to_s
        ]
      end
    end
  end
end

