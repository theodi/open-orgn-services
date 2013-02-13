# Events

Given /^an event in Eventbrite called "(.*?)" with id (\d+)$/ do |title, id|
  @event_title = title
  @event_id = id
  @price = 0
  @event_live = true
end

Given /^the event is happening on (\d+)\-(\d+)\-(\d+)$/ do |year, month, day|
  @event_date = Date.new(year.to_i, month.to_i, day.to_i)
end

Given /^that event is not live$/ do
  @event_live = false
end

Given /^the price of the event is ([\d\.]+)$/ do |price|
  @price = price.to_f
end

# Registration

Given /^I have registered for a ticket$/ do
  @tickets = 1
end

Given /^I have registered for two tickets$/ do
  @tickets = 2
end

When /^I sign up to that event and ask to be invoiced$/ do
  # Check the attendees
  VCR.use_cassette("#{@scenario_name}/needs_invoice") do
    AttendeeLister.perform(@event_id)
  end
end

When /^I sign up to that event and get a free ticket$/ do
  # Check the attendees
  VCR.use_cassette("#{@scenario_name}/does_not_need_invoice") do
    AttendeeLister.perform(@event_id)
  end
end

# Queueing

When /^we poll eventbrite for all events$/ do
  # Check the events list
  VCR.use_cassette("#{@scenario_name}/all_events") do
    EventLister.perform
  end
end

Then /^that event should be queued for attendee checking$/ do
  pending
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeLister, @event_id)
end

Then /^that event should not be queued for attendee checking$/ do
  pending
  # Set expectation
  Resque.should_not_receive(:enqueue).with(AttendeeLister, @event_id)
end