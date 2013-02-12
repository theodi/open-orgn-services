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

Given /^that company has a invoice contact email of "(.*?)"$/ do |email|
  @invoice_email = email
end

Given /^that company has a invoice phone number of "(.*?)"$/ do |phone|
  @invoice_phone = phone
end

Given /^that company has a invoice address of "(.*?)"$/ do |invoice_address|
  @invoice_address = invoice_address
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