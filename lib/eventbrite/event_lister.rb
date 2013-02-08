class EventLister
  @queue = :invoicing

  # Public: Inspect the list of event on Eventbrite
  #
  # Examples
  #
  #   EventLister.perform
  #   # => nil
  #
  # Returns nil. Queues further jobs to handle inspection of attendee lists.
  def self.perform
    e = EventbriteClient.new ({ :app_key => ENV["EVENTBRITE_API_KEY"], :user_key => ENV["EVENTBRITE_USER_KEY"]})
    if response = e.organizer_list_events(id: ENV['EVENTBRITE_ORGANIZER_ID'])
      response.parsed_response['events'].each do |event|
        e = event['event']
        if e['id'] && e['status'] == 'Live'
          Resque.enqueue(AttendeeLister, e['id'].to_s)
        end
      end
    end
  end
end