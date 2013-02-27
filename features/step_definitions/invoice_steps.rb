Given /^my order number is (#{INTEGER})$/ do |order_number|
  @order_number = order_number
end

# loads of duplication here
# deliberately left in to prompt us to converge on phrasing style

Given /^I entered a purchase order number "(.*?)"$/ do |po_number|
  @purchase_order_number = po_number
end

Given /^my purchase order reference is "(.*?)"$/ do |purchase_order_reference|
  @purchase_order_reference = purchase_order_reference
end

# loads of duplication here
# deliberately left in to prompt us to converge on phrasing style

Given /^I entered a tax registration number "(.*?)"$/ do |tax_reg_number|
  @tax_reg_number = tax_reg_number
end

Given /^my organisation has a tax registration number "(.*?)"$/ do |tax_registration_number|
  @tax_registration_number = tax_registration_number
end

# payment

Given /^I paid with Paypal$/ do
  @payment_method = 'paypal'
end

Given /^I requested an invoice$/ do
  @payment_method = 'invoice'
end

# invoice description

Then /^the invoice description should read "(.*?)"$/ do |invoice_description|
  @invoice_description = invoice_description
end
