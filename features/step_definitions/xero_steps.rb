require 'digest/md5'

# Utility functions to marshal setup variables into appropriate hashes

def user_details
  {
    :company => @company,
    :first_name => @first_name,
    :last_name => @last_name,
    :email => @email,
    :invoice_email => @invoice_email,
    :phone => @phone,
    :invoice_phone => @invoice_phone,
    :address_line1 => @address_line1,
    :address_city => @address_city,
    :address_country => @address_country,
    :invoice_address_line1 => @invoice_address_line1,
    :invoice_address_city => @invoice_address_city,
    :invoice_address_country => @invoice_address_country,
  }
end

def event_details
  {
    :id => @event_id,
    :date => @event_date
  }
end

def payment_details
  {
    :price => @price,
    :quantity => @quantity,
    :overseas_vat_reg_no => @vat_reg_number
  }
end

# Shared setup for the Xero connection

def xero
  $xero ||= Xeroizer::PrivateApplication.new(
    ENV["XERO_CONSUMER_KEY"],
    ENV["XERO_CONSUMER_SECRET"],
    ENV["XERO_PRIVATE_KEY_PATH"]
  )
end

# Xero contacts

Given /^there is a contact in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("#{@scenario_name}/xero_contact_lookup") do
    xero.Contact.all(:where => %{Name == "#{contact}"}).should_not be_empty
  end
end

Given /^there is no contact in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("#{@scenario_name}/xero_contact_lookup") do
    xero.Contact.all(:where => %{Name == "#{contact}"}).should be_empty
  end
end

Then /^the total cost to be invoiced should be ([\d\.]+)$/ do |cost|
  @total_cost = cost
end

Then /^the net cost to be invoiced should be ([\d\.]+)$/ do |cost|
  @net_cost = cost
end

Then /^a contact should exist in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("#{@scenario_name}/xero_contact_lookup_post_create") do
    @contact = xero.Contact.all(:where => %{Name == "#{contact}"}).first
  end
  @contact.should_not be_nil
end

Then /^that contact should have email "(.*?)"$/ do |email|
  @contact.email_address.should == email
end

Then /^that contact should have phone number "(.*?)"$/ do |number|
  @contact.phones.find{|x| x.type == "DEFAULT"}.number.should == number
end

Then /^that contact should have postal address \((.*?)\) of "(.*?)"$/ do |field, value|
  @contact.addresses.find{|x| x.type='DEFAULT'}.send(field).should == value
end

# Invoices 

Given /^I have already been invoiced$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^an invoice should be raised in Xero against "(.*?)"$/ do |contact_name|
  VCR.use_cassette("#{@scenario_name}/xero_contact_lookup") do
    @contact = xero.Contact.all(:where => %{Name == "#{contact_name}"}).first
  end
  VCR.use_cassette("#{@scenario_name}/xero_invoices_lookup") do
    @invoice = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"}).last
  end
  @invoice.should_not be_nil
end

Then /^I should not be invoiced again$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should be a draft$/ do
  @invoice.status.should == 'DRAFT'
end

Then /^that invoice should include the reference "(.*?)"$/ do |reference|
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should include the note "(.*?)"$/ do |note|
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should be due on (\d+)\-(\d+)\-(\d+)$/ do |year, month, day|
  VCR.use_cassette("#{@scenario_name}/due_date_for_invoice") do
    @invoice.due_date.should == Date.new(year.to_i, month.to_i, day.to_i)
  end
end

Then /^that invoice should have a total of ([\d\.]+)$/ do |total|
  VCR.use_cassette("#{@scenario_name}/total_for_invoice") do
    @invoice.total.should == total.to_f
  end
end

# Line items 

Then /^that invoice should contain (\d+) line item$/ do |line_item_count|
  VCR.use_cassette("#{@scenario_name}/line_items_for_invoice") do
    @line_items = @invoice.line_items
    @line_items.count.should == line_item_count.to_i
  end
  if @line_items.count == 1
    @line_item = @line_items.first
  end
end

Then /^that line item should have a quantity of (\d+)$/ do |quantity|
  @line_item.quantity.should == quantity.to_i
end

Then /^that line item should not have an account code set$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that line item should have the description "(.*?)"$/ do |description|
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should show that payment has been received$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should show that payment has not been received$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should show that the payment was made with Paypal$/ do
  pending # express the regexp above with the code you wish you had
end

# Invoice queue

When /^the attendee invoicer runs$/ do
  # Invoice
  VCR.use_cassette("#{@scenario_name}/raise_invoice_in_xero") do
    AttendeeInvoicer.perform(user_details, event_details, payment_details)
  end
end

Then /^I should be added to the invoicing queue$/ do
  pending
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, user_details, event_details, payment_details)
end

Then /^I should not be added to the invoicing queue$/ do
  pending
  # Set expectation
  Resque.should_not_receive(:enqueue)
end

Then /^the attendee invoicer should be requeued$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, user_details, event_details, payment_details)
end