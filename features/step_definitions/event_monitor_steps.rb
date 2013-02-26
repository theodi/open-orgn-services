When /^we poll eventbrite for all events$/ do
  # Check the events list
  EventMonitor.perform
end

Then /^that event should be queued for attendee checking$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeMonitor, event_details).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^that event should not be queued for attendee checking$/ do
  # Set expectation
  Resque.should_not_receive(:enqueue).with(AttendeeMonitor, event_details)
  Resque.should_receive(:enqueue).any_number_of_times
end

