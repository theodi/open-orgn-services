module Reports
  class Row
    attr_reader :product, :coupon_code, :transactions

    def initialize(product, coupon_code, transactions)
      @product      = product
      @coupon_code  = coupon_code
      @transactions = transactions
    end

    def title
      "#{product.handle} #{coupon_code}"
    end

    def signup_count
      transactions.count
    end

    def booking_value
      if product.handle =~ /monthly$/
        product.price_in_cents * 12 / 100
      else
        product.price_in_cents / 100
      end
    end

    def net
      transactions.reduce(0) do |total, transaction|
        total + transaction.net_total
      end / 100
    end

    def tax
      '%.2f' % (0.2 * net)
    end

    def total
      '%.2f' % (1.2 * net)
    end

    def row
      [
        title,
        booking_value,
        signup_count,
        net.to_s,
        tax,
        total
      ]
    end
  end
end

