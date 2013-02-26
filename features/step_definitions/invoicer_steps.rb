# Invoice queue

When /^the attendee invoicer runs$/ do
  # Invoice
  Invoicer.perform(create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash)
end

Then /^the attendee invoicer should be requeued$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash)
end