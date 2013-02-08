When /^the attendee invoicer runs$/ do
  VCR.use_cassette('raise_invoice_in_xero') do
    AttendeeInvoicer.perform({:email => @email}, {:id => @event_id}, {:amount => @price})
  end
end

Given /^'james\.smith@theodi\.org' already exists as a contact in Xero$/ do
  VCR.use_cassette('xero_contact_lookup') do
    xero = Xeroizer::PrivateApplication.new(
        ENV["XERO_CONSUMER_KEY"],
        ENV["XERO_CONSUMER_SECRET"],
        ENV["XERO_PRIVATE_KEY_PATH"]
    )
    xero.Contact.all(:where => 'EmailAddress == "james.smith@theodi.org"') != []
  end
end

Given /^'tom\.heath@theodi\.org' does not already exist as a contact in Xero$/ do
  VCR.use_cassette('xero_contact_inverse_lookup') do
    xero = Xeroizer::PrivateApplication.new(
        ENV["XERO_CONSUMER_KEY"],
        ENV["XERO_CONSUMER_SECRET"],
        ENV["XERO_PRIVATE_KEY_PATH"]
    )
    xero.Contact.all(:where => 'EmailAddress == "tom.heath@theodi.org"') == []
  end
end