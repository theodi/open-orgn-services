Given /^my first name is "(.*?)"$/ do |name|
  @first_name = name
end

Given /^my last name is "(.*?)"$/ do |name|
  @last_name = name
end

Given /^I do not work for anyone$/ do
  @company = nil
end

Given /^I work for "(.*?)"$/ do |company|
  @company = company
end

Given /^my email address is "(.*)"$/ do |email|
  @email = email
end

Given /^my phone number is "(.*?)"$/ do |phone|
  @phone = phone
end

Given /^my address \((.*?)\) is "(.*?)"$/ do |type, value|
  instance_variable_set("@address_#{type}", value)
end

Given /^that company has an invoice contact email of "(.*?)"$/ do |email|
  @invoice_email = email
end

Given /^that company has an invoice phone number of "(.*?)"$/ do |phone|
  @invoice_phone = phone
end

Given /^that company has an invoice address \((.*?)\) of "(.*?)"$/ do |type, value|
  instance_variable_set("@invoice_address_#{type}", value)
end

Given /^my order number is (#{INTEGER})$/ do |order_number|
  @order_number = order_number
end

Given /^I entered a purchase order number "(.*?)"$/ do |po_number|
  @purchase_order_number = po_number
end

Given /^I entered a VAT registration number "(.*?)"$/ do |vat_reg_number|
  @vat_reg_number = vat_reg_number
end

Given /^I entered a membership number "(.*?)"$/ do |membership_number|
  @membership_number = membership_number
end

Given /^I paid with Paypal$/ do
  @payment_method = :paypal
end

Given /^I requested an invoice$/ do
  @payment_method = :invoice
end