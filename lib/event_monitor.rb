require 'eventbrite-client'

class EventMonitor
  def initialize options = {}
    @event_id = options[:event_id]
  end

  def check_invoices
    e = EventbriteClient.new ({ :app_key => ENV["EVENTBRITE_API_KEY"], :user_key => ENV["EVENTBRITE_USER_KEY"]})
    e.event_list_attendees id: @event_id, page: 0
  end
end