require "open-orgn-services"

describe OrderMonitor do
  it 'checks for orders since midnight' do
    expect(Eventbrite::Client).to receive(:orders_since).with(Time.now.at_midnight)
    OrderMonitor.perform
  end

  it 'enqueues each order for attendee processing' do
    allow(Eventbrite::Client).to receive(:orders_since).and_yield({"resource_uri" => "link"})
    expect(Resque).to receive(:enqueue).with(OrderInvoicer, "link")
    OrderMonitor.perform
  end
end
