When /^the attendee monitor runs$/ do
  # Check the attendees
  AttendeeMonitor.perform(create_attendee_monitor_event_hash)
end

Then(/^I should be given the "(.*?)" membership$/) do |level|
  @membership = level
end

When /^my details should be added to the Capsule queue$/ do
  membership = {
    'product_name' => @membership,
    'supporter_level' => @membership,
    'join_date' => Date.today,
    'contact_email' => @email
  }

  party = {
    'name' => @first_name + " " + @last_name,
    'email' => @email
  }

  Resque.should_receive(:enqueue).with(SendSignupToCapsule, party, membership).once
  Resque.should_receive(:enqueue).with(Invoicer, kind_of(Hash), kind_of(Hash), kind_of(String)).any_number_of_times
  Resque.should_receive(:enqueue).with(SendSignupToCapsule, kind_of(Hash), kind_of(Hash)).any_number_of_times
end
