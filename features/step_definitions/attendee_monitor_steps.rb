When /^the attendee monitor runs$/ do
  # Check the attendees
  AttendeeMonitor.perform(create_attendee_monitor_event_hash)
end
