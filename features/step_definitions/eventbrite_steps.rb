# Events

Given /^an event in Eventbrite called "(.*?)" with id (#{INTEGER})$/ do |title, id|
  @event_title = title
  @event_id = id.to_s
  @price = 0
  @event_live = true
end

Given /^the event is happening on (#{DATE})$/ do |date|
  @event_date = date
end

Given /^that event is not live$/ do
  @event_live = false
end

Given /^the price of the event is (#{FLOAT})$/ do |price|
  @price = price
end

# Registration

Given /^I have registered for a ticket$/ do
  @quantity = 1
end

Given /^I have registered for two tickets$/ do
  @quantity = 2
end

When /^I sign up to that event and ask to be invoiced$/ do
  # Check the attendees
  AttendeeLister.perform(@event_id)
end

When /^I sign up to that event and get a free ticket$/ do
  # Check the attendees
  AttendeeLister.perform(@event_id)
end

# Queueing

When /^we poll eventbrite for all events$/ do
  # Check the events list
  EventLister.perform
end

Then /^that event should be queued for attendee checking$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeLister, @event_id).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^that event should not be queued for attendee checking$/ do
  # Set expectation
  Resque.should_not_receive(:enqueue).with(AttendeeLister, @event_id)
  Resque.should_receive(:enqueue).any_number_of_times
end