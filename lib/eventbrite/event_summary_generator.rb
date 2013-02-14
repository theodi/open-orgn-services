class EventSummaryGenerator
  
  @queue = :invoicing
  
  def self.perform(events)
    data = {}
    events.each do |event|
      # Get ticket info
      tickets = []
      if event[:ticket_types]
        event[:ticket_types].each do |ticket_type|
          tickets << {
            :@type => "http://schema.org/Offer",
            :name => ticket_type[:name],
            :price => ticket_type[:price],
            :priceCurrency => ticket_type[:currency],
            :validFrom => ticket_type[:starts_at],
            :validThrough => ticket_type[:ends_at],
            :inventoryLevel => ticket_type[:remaining]
          }
        end
      end
      # Marshal all event data
      data[event[:url]] = {
        :@type => "http://schema.org/Event",
        :startDate => event[:starts_at],
        :endDate => event[:ends_at],
        :location => {
          :@type => "http://schema.org/Place",
          :name => event[:location],
          # :address => {
          #   :@type => "http://schema.org/PostalAddress",
          #   :name => nil,
          #   :streetAddress => nil,
          #   :addressLocality => nil,
          #   :postalCode => nil,
          #   :addressCountry => nil
          # },          
        },
        # :geo => {
        #   :latitude => nil,
        #   :longitude => nil
        # },
        :offers => tickets
      }
    end
    # Generate JSON
    json = JSON.pretty_generate(data, :indent => '  ')
    # Enqueue
    Resque.enqueue(EventSummaryUploader, json)
  end
  
end