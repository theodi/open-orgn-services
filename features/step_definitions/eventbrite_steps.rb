# Events

Given /^an event in Eventbrite called "(.*?)" with id (#{INTEGER})$/ do |title, id|
  @events ||= []
  @events << {
    'title' => title,
    'id'    => id.to_s,
    'live'  => true
  }
end

Given /^another event in Eventbrite called "(.*?)" with id (#{INTEGER})$/ do |title, id|
  @events << {
    'title' => title,
    'id'    => id.to_s,
    'live'  => true
  }
end

Given /^the event is happening on (#{DATE})$/ do |date|
  @events.last['date'] = date
end

Given /^the event is happening in the past$/ do
  # this is set in eventbrite
end

Given /^that event is not live$/ do
  @events.last['live'] = false
end

Given /^I have signed up for (#{INTEGER}) tickets? called "(.*?)" which has a net price of (#{FLOAT})$/ do |count, name, price|
  @quantity = count
  @ticket_type = name
  @net_price = price
end

Given /^the gross price of the event in Eventbrite is (#{FLOAT})$/ do |price|
  @gross_price = price
end

Given /^that event has a url '(.*?)'$/ do |url|
  @events.last['url'] = url
end

Given /^that event starts at (#{DATETIME})$/ do |datetime|
  @events.last['starts_at'] = datetime
end

Given /^that event ends at (#{DATETIME})$/ do |datetime|
  @events.last['ends_at'] = datetime
end

Given /^that event is being held at '(.*?)'$/ do |location|
  @events.last['location'] = location
end

Given /^that event has (#{INTEGER}) tickets called "(.*?)" which cost ([A-Z]{3}) (#{FLOAT})$/ do |tickets, name, currency, price|
  @events.last['ticket_types'] ||= []
  @events.last['ticket_types'] << {
    'remaining' => tickets,
    'name'      => name,
    'price'     => price,
    'currency'  => currency
  }
end

Given /^that ticket type is on sale from (#{DATETIME})$/ do |datetime|
  @events.last['ticket_types'].last['starts_at'] = datetime
end

Given /^that ticket type is on sale until (#{DATETIME})$/ do |datetime|
  @events.last['ticket_types'].last['ends_at'] = datetime
end

Then /^the net price of the event is (#{FLOAT})$/ do |price|
  @net_price = price
end

# Registration

Given /^I have registered for a ticket$/ do
  @quantity = 1
end

Given /^I have registered for two tickets$/ do
  @quantity = 2
end

When /^the attendee lister runs$/ do
  # Check the attendees
  AttendeeLister.perform(event_details)
end

# Queueing

When /^we poll eventbrite for all events$/ do
  # Check the events list
  EventLister.perform
end

Then /^that event should be queued for attendee checking$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeLister, event_details).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^that event should not be queued for attendee checking$/ do
  # Set expectation
  Resque.should_not_receive(:enqueue).with(AttendeeLister, event_details)
  Resque.should_receive(:enqueue).any_number_of_times
end

Given /^that event has not sold any tickets$/ do
  # nothing to check here, we rely on the cassette or the remote API being correct. Probably a bit lame
end

Then /^no errors should be raised$/ do
  # Errors will be raised in the previous step, so we don't need to check explicitly here
end