
Given /^I have a membership id "(.*?)"$/ do |membership_id|
  @membership_id = membership_id
end

Given /^I requested (\d+) membership at the level called "(.*?)" which has a base annual price of (\d+)$/ do |quantity, membership_level, base_price|
  @quantity = quantity
  @membership_level = membership_level
  @base_price = base_price
end

When /^the signup processor runs$/ do
  organization, contact_person, billing, purchase = create_signup_processor_membership_hash
  SignupProcessor.perform(organization, contact_person, billing, purchase)
end