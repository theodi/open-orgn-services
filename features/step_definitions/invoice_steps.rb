Given /^my order number is (#{INTEGER})$/ do |order_number|
  @order_number = order_number
end

Given /^I entered a purchase order number "(.*?)"$/ do |po_number|
  @purchase_order_number = po_number
end

Given /^I entered a tax registration number "(.*?)"$/ do |tax_reg_number|
  @tax_reg_number = tax_reg_number
end

Given /^I paid with Paypal$/ do
  @payment_method = 'paypal'
end

Given /^I requested an invoice$/ do
  @payment_method = 'invoice'
end