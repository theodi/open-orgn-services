Given /^I have an invoice contact email of "(.*?)"$/ do |email|
  @invoice_email = email
end

Given /^I have an invoice phone number of "(.*?)"$/ do |phone|
  @invoice_phone = phone
end

Given /^I have an invoice address \((.*?)\) of "(.*?)"$/ do |type, value|
  instance_variable_set("@invoice_#{type}", value)
end

Given /^I have a membership number "(.*?)"$/ do |membership_number|
  @membership_number = membership_number
end

Given /^a membership level called "(.*?)" which has a base annual cost of (\d+)$/ do |level, cost|
  @level = level
  @cost = cost
end

Given /^my purchase order number is (\d+)$/ do |po_number|
  @po_number = po_number
end

When /^the signup processor runs$/ do
  SignupMonitor.perform(create_signup_processor_membership_hash)
end