# Invoice queue

When /^the attendee invoicer runs$/ do
  # Invoice
  Invoicer.perform(user_details, event_details, payment_details)
end

Then /^the attendee invoicer should be requeued$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, user_details, event_details, payment_details)
end