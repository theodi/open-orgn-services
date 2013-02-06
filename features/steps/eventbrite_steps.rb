Given /^there is an event in Eventbrite$/ do
end

When /^I sign up to that event and ask to be invoiced$/ do
  # Set up some user details
end

Then /^I should be marked as wanting an invoice$/ do
  # Mock response from eventbrite API
  # https://www.eventbrite.co.uk/myevent?eid=5441375300
  # Poll eventbrite API for details
  # Find the relevant user and check the order type field
  pending # express the regexp above with the code you wish you had
end

Given /^I have asked to be invoiced$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^an invoice should be raised in Xero$/ do
  pending # express the regexp above with the code you wish you had
end
