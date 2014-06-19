
Given /^I have a membership id "(.*?)"$/ do |membership_id|
  @membership_id = membership_id
end

Given /^I requested (\d+) membership at the level called "(.*?)"$/ do |quantity, membership_level|
  @quantity = quantity
  @membership_level = membership_level
end

Given /^I requested membership at the level called "(.*?)"$/ do |membership_level|
  @membership_level = membership_level
end

When /^the signup processor runs$/ do
  organization, contact_person, billing, purchase = create_signup_processor_membership_hash
  SignupProcessor.perform(organization, contact_person, billing, purchase)
end

Given(/^I am paying by "(.*?)"$/) do |method|
  @payment_method = method
end

Given(/^I want to pay on an? "(.*?)" basis$/) do |period|
  @payment_freq = period
  # Even if paying monthly, invoices are raised annually
  @invoice_freq = 'annual'
end

Given(/^my payment reference is "(.*?)"$/) do |ref|
  @payment_ref = ref
end
