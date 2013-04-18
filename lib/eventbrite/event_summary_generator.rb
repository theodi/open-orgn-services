class EventSummaryGenerator
  
  @queue = :invoicing
  
  # Public: Generates a JSON summary of event listings
  #
  # events - an array containing a hash for each event. Each hash contains:
  #          'url'          - the canonical event URL
  #          'title'        - the event name
  #          'location'     - the textual location of the event (e.g. "Open Data Institute")
  #          'starts_at'    - the starting DateTime of the event
  #          'ends_at'      - the starting DateTime of the event
  #          'ticket_types' - an array of ticket types. Each one is a hash containing:
  #                           'name'      - the descriptive name of the ticket (e.g. 'Free Ticket')
  #                           'price'     - the price of the ticket
  #                           'currency'  - currency code, e.g. GBP
  #                           'starts_at' - when the ticket goes on sale
  #                           'ends_at'   - when the ticket is on sale until
  #                           'remaining' - the number of tickets available
  #
  # Examples
  #
  #   EventSummaryGenerator.perform([{:id => 1234, :title => 'Open Data for Dummies', ...}])
  #   # => nil
  #
  # Returns nil. Queues an EventSummaryUploader job to upload the JSON to the target location
  def self.perform(events)
    data = {}
    events.each do |event|
      # Marshal all event data
      if event['title'] =~ /lunchtime/
        capacity = event['capacity']
      else
        capacity = nil
      end
      
      data[event['url']] = {
        :name      => event['title'],
        :@type     => "http://schema.org/Event",
        :startDate => event['starts_at'],
        :endDate   => event['ends_at'],
        :capacity  => capacity
      }.compact
      if event['location']
        data[event['url']]['location'] = {
          :@type => "http://schema.org/Place",
          :name  => event['location'],
          # :address => {
          #   :@type => "http://schema.org/PostalAddress",
          #   :name => nil,
          #   :streetAddress => nil,
          #   :addressLocality => nil,
          #   :postalCode => nil,
          #   :addressCountry => nil
        }
        # :geo => {
        #   :latitude => nil,
        #   :longitude => nil
        # },
      end
      # Get ticket info
      tickets = []
      if event['ticket_types']
        event['ticket_types'].each do |ticket_type|
          tickets << {
            :@type           => "http://schema.org/Offer",
            :name           => ticket_type['name'],
            :price          => ticket_type['price'],
            :priceCurrency  => ticket_type['currency'],
            :validThrough   => ticket_type['ends_at'],
            :inventoryLevel => ticket_type['remaining']
          }
          tickets.last['validFrom'] = ticket_type['starts_at'] if ticket_type['starts_at']
        end
      end
      data[event['url']]['offers'] = tickets
    end
    # Generate JSON
    json = JSON.pretty_generate(data, :indent => '  ')
    # Enqueue
    Resque.enqueue(EventSummaryUploader, json)
  end
  
end