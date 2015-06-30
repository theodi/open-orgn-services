When /^the attendee monitor runs$/ do
  # Check the attendees
  AttendeeMonitor.perform(create_attendee_monitor_event_hash)
end

When /^my details should be added to the Capsule queue$/ do
  membership = {
    'product_name' => 'supporter',
    'supporter_level' => 'supporter',
    'join_date' => Date.today,
    'contact_email' => @email
  }

  party = {
    'name' => @first_name + " " + @last_name,
    'email' => @email
  }

  Resque.should_receive(:enqueue).with(Invoicer, kind_of(Hash), kind_of(Hash), kind_of(String)).any_number_of_times
  Resque.should_receive(:enqueue).with(SendSignupToCapsule, membership, party).once
end
