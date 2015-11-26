require "bigdecimal"
require_relative "report"
require_relative "signup"
require_relative "product_row"

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

      subscriptions.group_by(&:product_name).each do |product_group, subscriptions|
        table << ProductRow.row(product_group, subscriptions)
      end

      table
    end

    def subscriptions
      @subscriptions.map do |subscription|
        Signup.new(subscription, tax_charges)
      end
    end

    def tax_charges
      @tax_charges ||= transactions.select do |transaction|
        transaction.type == "Charge" && transaction.kind == "tax"
      end
    end
  end
end

