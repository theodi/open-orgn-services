require 'attendee_lister'

Given /^there is an event in Eventbrite with id (\d+)$/ do |id|
  # Store event ID
  @event_id = id
end

When /^'(.*)' signs up to that event and asks to be invoiced$/ do |email|
  # User details are entered on Eventbrite, and price is worked out
  @email = email
  @price = 0.66
end

When /^'(.*)' signs up to that event and gets a free ticket$/ do |email|
  # User details are entered on Eventbrite, and price is worked out
  @email = email  
  @price = 0
end

Then /^he should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, @email, @price)
  # Check the attendees
  VCR.use_cassette('needs_invoice') do
    AttendeeLister.perform(@event_id)
  end
end

Then /^he should not be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_not_receive(:enqueue)
  # Check the attendees
  VCR.use_cassette('does_not_need_invoice') do
    AttendeeLister.perform(@event_id)
  end
end

Given /^'(.*)' needs to be invoiced for ([\d\.]+)$/ do |email, price|
end

Given /^I have asked to be invoiced$/ do
  @email = email
  @price = price.to_f
end

Then /^an invoice should be raised in Xero$/ do
  pending # express the regexp above with the code you wish you had
end
