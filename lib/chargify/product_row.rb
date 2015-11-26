module Reports
  class ProductRow
    attr_reader :product_group, :subscriptions

    def self.row(*args)
      new(*args).row
    end

    def initialize(product_group, subscriptions)
      @product_group = product_group
      @subscriptions = subscriptions
    end

    def count
      subscriptions.count
    end

    def booking_value
      net_total / count
    end

    def net_total
      subscriptions.reduce(0) do |total, subscription|
        total + subscription.net_total
      end
    end

    def tax_total
      subscriptions.reduce(0) do |total, subscription|
        total + subscription.tax_total
      end
    end

    def total
      subscriptions.reduce(0) do |total, subscription|
        total + subscription.total
      end
    end

    def row
      [
        product_group,
        "%.2f" % booking_value,
        count,
        "%.2f" % net_total,
        "%.2f" % tax_total,
        "%.2f" % total
      ]
    end
  end
end

