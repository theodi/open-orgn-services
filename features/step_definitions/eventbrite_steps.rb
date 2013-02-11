Given /^there is an event in Eventbrite with id (\d+)$/ do |id|
  # Store event ID
  @event_id = id
  @price = 0
end

Given /^there is an event in Eventbrite with id (\d+) which is not live$/ do |id|
  # Store event ID
  @event_id = id
end

Given /^there is an event in Eventbrite with id (\d+) which costs ([\d\.]+) to attend$/ do |id, price|
  # Store event ID
  @event_id = id
  @price = 0.66
end

Given /^an event in Eventbrite called "(.*?)" with id (\d+)$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^the event is happening on (\d+)\-(\d+)\-(\d+)$/ do |year, month, day|
  pending # express the regexp above with the code you wish you had
end

Given /^the price of the event is (\d+)\.(\d+)$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^the eventbrite fee is (\d+)\.(\d+)$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^I have registered for a ticket$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I have registered for two tickets$/ do
  pending # express the regexp above with the code you wish you had
end

When /^we poll eventbrite for all events$/ do
  # Check the events list
  VCR.use_cassette('all_events') do
    EventLister.perform
  end
end

Then /^that event should be queued for attendee checking$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeLister, @event_id)
end

Then /^that event should not be queued for attendee checking$/ do
  # Set expectation
  Resque.should_not_receive(:enqueue).with(AttendeeLister, @event_id)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, {:email => @email}, {:id => @event_id}, {:amount => @price})
end

Then /^I should not be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_not_receive(:enqueue)
end

When /^I sign up to that event and ask to be invoiced$/ do
  # Check the attendees
  VCR.use_cassette('needs_invoice') do
    AttendeeLister.perform(@event_id)
  end
end

When /^I sign up to that event and get a free ticket$/ do
  # Check the attendees
  VCR.use_cassette('does_not_need_invoice') do
    AttendeeLister.perform(@event_id)
  end
end