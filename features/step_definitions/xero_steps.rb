Given /^there is a contact in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("xero_contact_lookup_#{contact}") do
    xero = Xeroizer::PrivateApplication.new(
        ENV["XERO_CONSUMER_KEY"],
        ENV["XERO_CONSUMER_SECRET"],
        ENV["XERO_PRIVATE_KEY_PATH"]
    )
    xero.Contact.all(:where => %{EmailAddress == "#{contact}"'}).should_not be_empty
  end
end

Given /^there is no contact in Xero for "(.*?)"$/ do |contact|
  VCR.use_cassette("xero_contact_lookup_#{contact}") do
    xero = Xeroizer::PrivateApplication.new(
        ENV["XERO_CONSUMER_KEY"],
        ENV["XERO_CONSUMER_SECRET"],
        ENV["XERO_PRIVATE_KEY_PATH"]
    )
    xero.Contact.all(:where => %{EmailAddress == "#{contact}"'}).should be_empty
  end
end

When /^the attendee invoicer runs$/ do
  VCR.use_cassette('raise_invoice_in_xero') do
    AttendeeInvoicer.perform({:email => @email}, {:id => @event_id}, {:amount => @price})
  end
end

Then /^the total cost to be invoiced should be ([\d\.]+)$/ do |cost|
  @total_cost = cost
end

Then /^the net cost to be invoiced should be ([\d\.]+)$/ do |cost|
  @net_cost = cost
end

Then /^a contact should be created in Xero for "(.*?)"$/ do |contact|
  pending # express the regexp above with the code you wish you had
end

Then /^an invoice should be raised in Xero against "(.*?)"$/ do |contact|
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
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have phone number "(.*?)"$/ do |number|
  pending # express the regexp above with the code you wish you had
end

Then /^that contact should have address "(.*?)"$/ do |address|
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