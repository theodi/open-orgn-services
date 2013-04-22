class EventMonitor
  @queue = :invoicing

  # Public: Inspect the list of event on Eventbrite
  #
  # Examples
  #
  #   EventMonitor.perform
  #   # => nil
  #
  # Returns nil. Queues further jobs to handle inspection of attendee lists.
  def self.perform
    events = []
    e = EventbriteClient.new ({ :app_key => ENV["EVENTBRITE_API_KEY"], :user_key => ENV["EVENTBRITE_USER_KEY"]})
    if response = e.organizer_list_events(id: ENV['EVENTBRITE_ORGANIZER_ID'])
      response.parsed_response['events'].each do |event|
        e = event['event']
        if e['id'] && e['status'] == 'Live' && Date.parse(e['start_date']) >= Date.today
          # Tickets
          tickets = []
          e['tickets'].each do |ticket|
            t = ticket['ticket']
            tickets << {
              'name'      => t['name'],
              'remaining' => t['quantity_available'] - t['quantity_sold'],
              'price'     => t['price'].delete(',').to_f,
              'currency'  => t['currency'],
              'ends_at'   => DateTime.parse(t['end_date']).to_s
            }
            tickets.last['starts_at'] = DateTime.parse(t['start_date']).to_s if t['start_date']
          end
          # Everything else
          events << {
            'id'           => e['id'].to_s,
            'live'         => true,
            'title'        => e['title'],
            'url'          => e['url'],
            'starts_at'    => DateTime.parse(e['start_date']).to_s,
            'ends_at'      => DateTime.parse(e['end_date']).to_s,
            'capacity'     => e['capacity'],
            'ticket_types' => tickets,
            'capacity'     => get_capacity(e)
          }
          events.last['location'] = e['venue']['name'] if e['venue']
        end
      end
    end
    # Queue subsequent jobs
    events.each do |event| 
      Resque.enqueue(AttendeeMonitor, event)
    end
    Resque.enqueue(EventSummaryGenerator, events)
  end
  
  # If an event only has one ticket type, or the capacity has not been specified, we need to add together the ticket types to get the capacity
  def self.get_capacity(event) 
    if event['capacity'] > 0
      capacity = event['capacity']
    else
      capacity = 0
      if event['tickets']
        event['tickets'].each do |ticket|
          capacity += ticket['ticket']['quantity_available']
        end
      end
    end 
    return capacity
  end
  
end
