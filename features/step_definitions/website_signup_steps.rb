Given /^my membership number is "(.*?)"$/ do |membership_number|
  @membership_id = membership_number  
end

Given(/^my organisation has a company number "(.*?)"$/) do |company_number|
  @company_number = company_number
end