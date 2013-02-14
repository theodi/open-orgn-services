class AttendeeLister

  @queue = :invoicing

  # Public: Inspect the list of attendees for an event
  #
  # event_id - the ID of the event in Eventbrite
  #
  # Examples
  #
  #   AttendeeLister.perform(123456789)
  #   # => nil
  #
  # Returns nil. Queues further jobs to handle invoice raising.
  def self.perform(event_id)
    e = EventbriteClient.new ({ :app_key => ENV["EVENTBRITE_API_KEY"], :user_key => ENV["EVENTBRITE_USER_KEY"]})
    if response = e.event_list_attendees(id: event_id, page: 0)
      response.parsed_response['attendees'].each do |attendee|
        a = attendee['attendee']
        if a['order_type'] == "Send an Invoice - Payment Not Received"
          Resque.enqueue(AttendeeInvoicer, {:email => a['email']}, {:id => event_id}, {:price => a['amount_paid'].to_f/1.2})
        end
      end
    end
  end

end