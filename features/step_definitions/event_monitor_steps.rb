When /^we poll eventbrite for all events$/ do
  # Check the events list
  EventMonitor.perform
end

Then /^that event should be queued for attendee checking$/ do
  # Set expectation
  Resque.stub(:enqueue)
  Resque.should_receive(:enqueue).with(AttendeeMonitor, create_attendee_monitor_event_hash).once
end

Then /^that event should not be queued for attendee checking$/ do
  # Set expectation
  Resque.stub(:enqueue)
  Resque.should_not_receive(:enqueue).with(AttendeeMonitor, create_attendee_monitor_event_hash)
end

