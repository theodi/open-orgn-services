# Invoice queue

When /^the attendee invoicer runs$/ do
  # Set some things that must exist, if they don't already
  @invoice_description ||= SecureRandom.hex(32)
  @base_price ||= SecureRandom.random_number(9999)
  @invoice_uid ||= create_invoice_uid
  # Invoice
  Invoicer.perform(create_invoice_to_hash, create_invoice_details_hash, @invoice_uid)
end

When /^I have not already been invoiced$/ do
  expect(Invoicer).to receive(:invoice_sent?).with(create_invoice_uid).once.and_return(false)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue) do |arg1, arg2, arg3|
    expect(arg1).to eq(Invoicer)
    expect(arg2).to eq(create_invoice_to_hash)
    expect(arg3['payment_method']).to eq(create_invoice_details_hash['payment_method'])
    expect(arg3['repeat']).to eq(create_invoice_details_hash['repeat'])
    expect(arg3['purchase_order_reference']).to eq(create_invoice_details_hash['purchase_order_reference'])
    expect(arg3['sector']).to eq(create_invoice_details_hash['sector'])

    create_invoice_details_hash['line_items'].each_with_index do |k, i|
      expect(arg3['line_items'][i]['quantity']).to eq(k['quantity'])
      expect(arg3['line_items'][i]['base_price']).to eq(k['base_price'])
      expect(arg3['line_items'][i]['description']).to eq(k['description'])
      expect(arg3['line_items'][i]['payment_method']).to eq(k['payment_method'])
      expect(arg3['line_items'][i]['discount_rate']).to eq(k['discount_rate'])
    end
  end
end

Then /^I should be added to the invoicing queue along with others$/ do
  allow(Resque).to receive(:enqueue)
  expect(Resque).to receive(:enqueue).with(Invoicer, create_invoice_to_hash, create_invoice_details_hash, create_invoice_uid).once
end

Then /^I should not be added to the invoicing queue$/ do
  expect(Resque).not_to receive(:enqueue).with(no_args)
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
