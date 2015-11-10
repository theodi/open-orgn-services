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
        count = @transactions.count { |txn| txn.type == 'Payment' && txn.product_id == product.id }
        amount = if product.handle =~ /monthly$/
          product.price_in_cents*12/100
        else
          product.price_in_cents/100
        end
        net = amount*count
        total, tax = 1.2*net, 0.2*net
        table << [product.handle, count.to_s, amount.to_i.to_s, net.to_i.to_s, tax.to_i.to_s, total.to_i.to_s]
      end
      table
    end
  end
end

