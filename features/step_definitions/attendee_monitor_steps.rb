
When /^the attendee lister runs$/ do
  # Check the attendees
  AttendeeMonitor.perform(event_details)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, user_details, event_details, payment_details).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^I should not be added to the invoicing queue$/ do
  Resque.should_not_receive(:enqueue).with do |klass, user, event, payment|
    payment[:order_number] == @order_number
  end
end