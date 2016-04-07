class OrderMonitor
  @queue = :invoicing

  def self.perform
    midnight = Time.now.at_midnight
    Eventbrite::Client.orders_since(midnight) do |order|
      Resque.enqueue(OrderInvoicer, order['resource_uri'])
    end
  end

end
