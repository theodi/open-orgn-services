# Invoice queue

When /^the attendee invoicer runs$/ do
  # Set some things that must exist, if they don't already
  @invoice_description ||= SecureRandom.hex(32)
  @base_price ||= SecureRandom.random_number(9999)
  # Invoice
  Invoicer.perform(create_invoice_to_hash, create_invoice_details_hash, create_invoice_uid)
end

When /^I have not already been invoiced$/ do
  Invoicer.should_receive(:invoice_sent?).with(create_invoice_uid).once.and_return(false)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  if create_invoice_uid.nil?
    Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash).once
  else
    Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash, create_invoice_uid).once
  end
end

Then(/^my booking should not be requeued$/) do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be added to the invoicing queue along with others$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash, create_invoice_uid).once
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
  Resque.should_receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash, create_invoice_uid).once
end

Given /^I have been sent an invoice$/ do
  Invoicer.should_receive(:invoice_sent?).with(create_invoice_uid).once.and_return(true)
end

Then /^my registration should not be sent to Xero$/ do
  Invoicer.should_not_receive(:invoice_contact)
end

Given(/^a uid has not been set$/) do
  Resque.redis.set(create_invoice_uid, nil)
end

Given(/^a uid is set$/) do
  Resque.redis.set(create_invoice_uid, true)
end