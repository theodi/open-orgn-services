# Invoice queue

When /^the attendee invoicer runs$/ do
  # Set some things that must exist, if they don't already
  @invoice_description ||= SecureRandom.hex(32)
  @base_price ||= SecureRandom.random_number(9999)
  # Invoice
  Invoicer.perform(create_invoice_to_hash, create_invoice_details_hash)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash).once
end

Then /^I should be added to the invoicing queue along with others$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^I should not be added to the invoicing queue$/ do
  Resque.should_not_receive(:enqueue).with do |klass, user, payment|
    payment[:description] == @invoice_description
  end
end

Then /^the attendee invoicer should be requeued$/ do
  # Set some things that must exist, if they don't already
  @invoice_description ||= SecureRandom.hex(32)
  @base_price ||= SecureRandom.random_number(9999)
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash).once
end