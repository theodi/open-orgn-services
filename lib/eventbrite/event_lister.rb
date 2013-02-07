class EventLister
  @queue = :invoicing

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