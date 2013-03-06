Given /^I signed up for membership at the level called "(.*?)"$/ do |level|
  @product_name = level
end

Given /^I signed up on (#{DATE})$/ do |date|
  @join_date = date
end

Given /^my membership number is "(.*?)"$/ do |membership_number|
  @membership_number = membership_number  
end