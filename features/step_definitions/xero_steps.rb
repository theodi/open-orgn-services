# Xero contacts

Given /^there is a contact in Xero for "(.*?)"$/ do |contact|
  @contact = xero.Contact.create( name: contact )
  expect(@contact).not_to be_nil
end

Given /^there is no contact in Xero for "(.*?)"$/ do |contact|
  expect(xero.Contact.all(:where => %{Name == "#{contact}"})).to be_empty
end

Then /^a contact should exist in Xero for "(.*?)"$/ do |contact|
  @contact = xero.Contact.all(:where => %{Name == "#{contact}"}).first
  expect(@contact).not_to be_nil
end

Then /^that contact should have email "(.*?)"$/ do |email|
  expect(@contact.email_address).to eq(email)
end

Then /^that contact should have phone number "(.*?)"$/ do |number|
  expect(@contact.phones.find{|x| x.type == "DEFAULT"}.number).to eq(number)
end

Then /^that contact should have postal address \((.*?)\) of "(.*?)"$/ do |field, value|
  expect(@contact.addresses.find{|x| x.type=='POBOX'}.send(field)).to eq(value)
end

Then /^that contact should have tax number "(.*?)"$/ do |tax_number|
  expect(@contact.tax_number).to eq(tax_number)
end

# Invoices

Given /^I have already been invoiced$/ do
  # Raise invoice
  @invoice_uid = SecureRandom.uuid
  Invoicer.perform(create_invoice_to_hash, create_invoice_details_hash, @invoice_uid)
  expect(xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"}).count).to eq(1)
end

Then /^an invoice should be raised in Xero against "(.*?)"$/ do |contact_name|
  @contact = xero.Contact.all(:where => %{Name == "#{contact_name}"}).first
  @invoice = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"}).last
  expect(@invoice).not_to be_nil
end

Then /^I should not be invoiced again$/ do
  @invoices = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"})
  expect(@invoices.count).to eq(1)
end

Then /^that invoice should be a draft$/ do
  expect(@invoice.status).to eq('DRAFT')
end

Then /^that invoice should include the reference "(.*?)"$/ do |reference|
  expect(@invoice.reference).to eq(reference)
end

Then /^the line item description should include "(.*?)"$/ do |text|
  @line_item ||= @invoice.line_items.first
  expect(@line_item.description).to include(text.to_s)
end

Then /^that invoice should be due on (#{DATE})$/ do |date|
  expect(@invoice.due_date).to eq(date)
end

Then /^that invoice should have a total of (#{FLOAT})$/ do |total|
  expect(@invoice.total).to eq(total)
end

# Line items

Then /^that invoice should contain (#{INTEGER}) line items?$/ do |line_item_count|
  @line_items = @invoice.line_items
  expect(@line_items.count).to eq(line_item_count)
  if @line_items.count == 1
    @line_item = @line_items.first
  end
end

Then(/^line item number (\d+) should have the description "(.*?)"$/) do |num, description|
  expect(@line_items[num - 1].description).to eq(description)
end

Then /^that line item should not have account code set$/ do
  expect(@line_item.account_code).to be_nil
end

Then /^that invoice should show that payment has been received$/ do
  expect(@invoice.line_items.last.description).to include("PAID")
end

Then(/^the invoice does not contain does not show paid with$/) do
  expect(@invoice.line_items.last.description).not_to include("PAID")
end

Then /^that invoice should show that payment has not been received$/ do
  expect(@invoice.amount_paid).to eq(0.0)
  expect(@invoice.amount_due).to eq(@invoice.total)
end

Then /^that invoice should show that the payment was made with Paypal$/ do
  expect(@invoice.line_items.last.description).to include("PAYPAL")
end

Then /^that invoice should show that the payment was made with a credit card$/ do
  expect(@invoice.line_items.last.description).to include("CREDIT CARD")
end

Then /^that invoice should show that the payment was made by direct debit$/ do
  expect(@invoice.line_items.last.description).to include("DIRECT DEBIT")
end

Then(/^that invoice should include the payment reference "(.*?)"$/) do |ref|
  expect(@invoice.line_items.last.description).to include(ref)
end

When(/^that invoice is deleted$/) do
  # Mock away the redis de-duplication here so we can test that deleted invoices are not reraised - this is an edge case now, but still worth checking in case we lose the redis state
  expect(Invoicer).to receive(:invoice_sent?).with(create_invoice_uid).once.and_return(true)
  @invoice.delete!
  @deleted_invoice = @invoice
  @invoice = nil
end

Then /^an invoice should not be raised in Xero against "(.*?)"$/ do |contact_name|
  @invoice = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"}).last
  expect(@invoice).to be_nil
end

Then(/^there should be (.*?) line items$/) do |num|
  expect(@invoice.line_items.count).to eq(num)
end

Given(/^that it's around the time the cassettes were recorded$/) do
  unless VCR.current_cassette.nil? || VCR.current_cassette.record_mode == :all
    datetime = File.ctime(VCR.current_cassette.file)
    Timecop.travel(datetime)
  end
end
