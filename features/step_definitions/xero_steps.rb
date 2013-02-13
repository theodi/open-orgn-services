require 'digest/md5'

def user_details
  {
    :company => @company,
    :first_name => @first_name,
    :last_name => @last_name,
    :email => @email,
    :invoice_email => @invoice_email,
    :phone => @phone,
    :invoice_phone => @invoice_phone,
  }
end

def event_details
  {
    :id => @event_id
  }
end

def payment_details
  {
    :amount => @price
  }
end

def xero
  $xero ||= Xeroizer::PrivateApplication.new(
    ENV["XERO_CONSUMER_KEY"],
    ENV["XERO_CONSUMER_SECRET"],
    ENV["XERO_PRIVATE_KEY_PATH"]
  )
end

Given /^there is a contact in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("xero_contact_lookup_#{contact}") do
    xero.Contact.all(:where => %{Name == "#{contact}"}).should_not be_empty
  end
end

Given /^there is no contact in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("xero_contact_lookup_#{contact}") do
    xero.Contact.all(:where => %{Name == "#{contact}"}).should be_empty
  end
end

Given /^I have already been invoiced$/ do
  pending # express the regexp above with the code you wish you had
end

When /^the attendee invoicer runs$/ do
  # Invoice
  hash = Digest::MD5.hexdigest(user_details.merge(event_details).merge(payment_details).inspect)
  VCR.use_cassette("raise_invoice_in_xero_#{hash}") do
    AttendeeInvoicer.perform(user_details, event_details, payment_details)
  end
end

Then /^the total cost to be invoiced should be ([\d\.]+)$/ do |cost|
  @total_cost = cost
end

Then /^the net cost to be invoiced should be ([\d\.]+)$/ do |cost|
  @net_cost = cost
end

Then /^a contact should exist in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("xero_contact_lookup_post_create_#{contact}") do
    @contact = xero.Contact.all(:where => %{Name == "#{contact}"}).first
  end
  @contact.should_not be_nil
end

Then /^an invoice should be raised in Xero against "(.*?)"$/ do |contact|
  pending # express the regexp above with the code you wish you had
end

Then /^I should not be invoiced again$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should be a draft$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should include the reference "(.*?)"$/ do |reference|
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should include the note "(.*?)"$/ do |note|
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should be due on (\d+)\-(\d+)\-(\d+)$/ do |year, month, day|
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have email "(.*?)"$/ do |email|
  @contact.email_address.should == email
end

Then /^that contact should have phone number "(.*?)"$/ do |number|
  @contact.phones.find{|x| x.type == "DEFAULT"}.number.should == number
end

Then /^that contact should have street address \(line1\) of "(.*?)"$/ do |address|
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have street address \(city\) of "(.*?)"$/ do |address|
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have street address \(country\) of "(.*?)"$/ do |address|
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have postal address \(line1\) of "(.*?)"$/ do |address|
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have postal address \(city\) of "(.*?)"$/ do |address|
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have postal address \(country\) of "(.*?)"$/ do |address|
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should have a total of ([\d\.]+)$/ do |total|
  pending # express the regexp above with the code you wish you had
end

Then /^that invoice should contain (\d+) line item$/ do |line_item_count|
  pending # express the regexp above with the code you wish you had
end

Then /^that line item should have a quantity of (\d+)$/ do |quantity|
  pending # express the regexp above with the code you wish you had
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

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, user_details, event_details, payment_details)
end

Then /^I should not be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_not_receive(:enqueue)
end

Then /^the attendee invoicer should be requeued$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(AttendeeInvoicer, user_details, event_details, payment_details)
end