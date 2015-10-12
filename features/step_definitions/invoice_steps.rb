Given /^my order number is (#{INTEGER})$/ do |order_number|
  @order_number = order_number
end

Given /^the invoice is due on (#{DATE})$/ do |date|
@invoice_due_date = date
end

Given /^the invoice amount is (.*?)$/ do |base_price|
  @base_price = base_price
end

Given /^the invoice description is "(.*?)"$/ do |invoice_description|
  @invoice_description = invoice_description
end

# loads of duplication here
# deliberately left in to prompt us to converge on phrasing style

Given /^my purchase order reference is "(.*?)"$/ do |purchase_order_reference|
  @payment_method = "invoice"
  @purchase_order_reference = purchase_order_reference
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

Given(/^I paid with a credit card$/) do
  @payment_method = 'credit_card'
end

Given(/^I paid by direct debit$/) do
  @payment_method = 'direct_debit'
end

# invoice description

Then /^the invoice description should read "(.*?)"$/ do |invoice_description|
  @invoice_description = invoice_description
  @line_items.first['description'] ||= invoice_description
end

Then /^the invoice price should be "(.*?)"$/ do |base_price|
  @base_price = base_price
  @line_items.first['base_price'] ||= base_price
end

Then(/^the invoice discount should be "(.*?)"$/) do |discount|
  @discount = discount.gsub!(/%\z/, "")
  @line_items.first['discount_rate'] ||= @discount
end

Then(/^the invoice should have (\d+) line items?$/) do |num|
  @line_items ||= []
  num.to_i.times { @line_items << {} }
end

Then(/^the invoice discount should be empty$/) do
  @line_items.first['discount_rate'] = nil
end

Then(/^line item number (\d+) should have a description of "(.*?)"$/) do |index, invoice_description|
  @line_items[index - 1]['description'] ||= invoice_description
end

Then(/^line item number (\d+) should have a price of (.*?)$/) do |index, price|
  @line_items[index - 1]['base_price'] ||= price
end

Then /^the supporter level should be "(.*?)"$/ do |supporter_level|
  @supporter_level = supporter_level
end

Then /^the invoice should be due on (#{DATE})$/ do |date|
  @invoice_due_date = date
end

# Spaces

When(/^my contact name is generated$/) do
  @contact_name = Invoicer.contact_name(create_invoice_to_hash)
end

Then(/^the generated name should be "(.*?)"$/) do |name|
  expect(@contact_name).to eq(name)
end
