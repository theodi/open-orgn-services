# Invoice queue

When /^the attendee invoicer runs$/ do
  # Invoice
  Invoicer.perform(create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash).once
  Resque.should_receive(:enqueue).any_number_of_times
end


## for new style invoicing queue
Then /^I should be added to the new style invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash).once
end
## for new style invoicing queue


Then /^I should not be added to the invoicing queue$/ do
  Resque.should_not_receive(:enqueue).with do |klass, user, event, payment|
    payment[:order_number] == @order_number
  end
end

Then /^the attendee invoicer should be requeued$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash)
end