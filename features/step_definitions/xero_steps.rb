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
    :address_line2 => @address_line2,
    :address_city => @address_city,
    :address_region => @address_region,
    :address_country => @address_country,
    :address_postcode => @address_postcode,
    :invoice_address_line1 => @invoice_address_line1,
    :invoice_address_line2 => @invoice_address_line2,
    :invoice_address_city => @invoice_address_city,
    :invoice_address_region => @invoice_address_region,
    :invoice_address_country => @invoice_address_country,
    :invoice_address_postcode => @invoice_address_postcode,
    :vat_number => @vat_reg_number,
  }.compact
end

def event_details
  @events.last.compact
end

def payment_details
  {
    :order_number => @order_number,
    :price => @net_price,
    :quantity => @quantity,
    :purchase_order_number => @purchase_order_number,
    :membership_number => @membership_number,
    :payment_method => @payment_method
  }.compact
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
  @contact = xero.Contact.all(:where => %{Name == "#{contact}"}).first
  @contact.should_not be_nil
end

Given /^there is no contact in Xero for "(.*?)"$/ do |contact|
  xero.Contact.all(:where => %{Name == "#{contact}"}).should be_empty
end

Then /^a contact should exist in Xero for "(.*?)"$/ do |contact|
  @contact = xero.Contact.all(:where => %{Name == "#{contact}"}).first
  @contact.should_not be_nil
end

Then /^that contact should have email "(.*?)"$/ do |email|
  @contact.email_address.should == email
end

Then /^that contact should have phone number "(.*?)"$/ do |number|
  @contact.phones.find{|x| x.type == "DEFAULT"}.number.should == number
end

Then /^that contact should have postal address \((.*?)\) of "(.*?)"$/ do |field, value|
  @contact.addresses.find{|x| x.type=='POBOX'}.send(field).should == value
end

Then /^that contact should have VAT number "(.*?)"$/ do |vat_number|
  @contact.tax_number.should == vat_number
end

# Invoices 

Given /^I have already been invoiced$/ do
  # Raise invoice
  AttendeeInvoicer.perform(user_details, event_details, payment_details)
  xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"}).count.should == 1
end

Then /^an invoice should be raised in Xero against "(.*?)"$/ do |contact_name|
  @contact = xero.Contact.all(:where => %{Name == "#{contact_name}"}).first
  @invoice = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"}).last
  @invoice.should_not be_nil
end

Then /^I should not be invoiced again$/ do
  pending
  @invoices = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{@contact.id}") AND Status != "DELETED"})
  @invoices.count.should == 1
end

Then /^that invoice should be a draft$/ do
  @invoice.status.should == 'DRAFT'
end

Then /^that invoice should include the reference "(.*?)"$/ do |reference|
  @invoice.reference.should == reference
end

Then /^the line item description should include "(.*?)"$/ do |text|
  @line_item ||= @invoice.line_items.first
  @line_item.description.should include(text.to_s)
end

Then /^that invoice should be due on (#{DATE})$/ do |date|
  @invoice.due_date.should == date
end

Then /^that invoice should have a total of (#{FLOAT})$/ do |total|
  @invoice.total.should == total
end

# Line items 

Then /^that invoice should contain (#{INTEGER}) line item$/ do |line_item_count|
  @line_items = @invoice.line_items
  @line_items.count.should == line_item_count
  if @line_items.count == 1
    @line_item = @line_items.first
  end
end

Then /^that line item should have a quantity of (#{INTEGER})$/ do |quantity|
  @line_item.quantity.should == quantity
end

Then /^that line item should not have account code set$/ do
  @line_item.account_code.should be_nil
end

Then /^that invoice should show that payment has been received$/ do
  pending
  @invoice.amount_due.should == 0.0
  @invoice.amount_paid.should == @invoice.total
end

Then /^that invoice should show that payment has not been received$/ do
  @invoice.amount_paid.should == 0.0
  @invoice.amount_due.should == @invoice.total
end

Then /^that invoice should show that the payment was made with Paypal$/ do
  pending # express the regexp above with the code you wish you had
end

# Invoice queue

When /^the attendee invoicer runs$/ do
  # Invoice
  AttendeeInvoicer.perform(user_details, event_details, payment_details)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, user_details, event_details, payment_details).once
  Resque.should_receive(:enqueue).any_number_of_times
end

Then /^I should not be added to the invoicing queue$/ do
  Resque.should_not_receive(:enqueue).with do |klass, user, event, payment|
    payment[:order_number] == @order_number
  end
end

Then /^the attendee invoicer should be requeued$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, user_details, event_details, payment_details)
end