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

Given /^my email address is '(.*)'$/ do |email|
  # Store event ID
  @email = email
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


Given /^'(.*)' needs to be invoiced for ([\d\.]+)$/ do |email, price|
  @email = email
  @price = price.to_f
end