
When /^the attendee lister runs$/ do
  # Check the attendees
  AttendeeMonitor.perform(create_attendee_monitor_event_hash)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^I should not be added to the invoicing queue$/ do
  Resque.should_not_receive(:enqueue).with do |klass, user, event, payment|
    payment[:order_number] == @order_number
  end
end