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

Given /^I entered a tax registration number "(.*?)"$/ do |tax_reg_number|
  @tax_reg_number = tax_reg_number
end

Given /^I entered a membership number "(.*?)"$/ do |membership_number|
  @membership_number = membership_number.to_s
end

Given /^I paid with Paypal$/ do
  @payment_method = 'paypal'
end

Given /^I requested an invoice$/ do
  @payment_method = 'invoice'
end

# Events

Given /^an event in Eventbrite called "(.*?)" with id (#{INTEGER})$/ do |title, id|
  @events ||= []
  @events << {
    'title' => title,
    'id'    => id.to_s,
    'live'  => true
  }
end

Given /^another event in Eventbrite called "(.*?)" with id (#{INTEGER})$/ do |title, id|
  @events << {
    'title' => title,
    'id'    => id.to_s,
    'live'  => true
  }
end

Given /^the event is happening on (#{DATE})$/ do |date|
  @events.last['starts_at'] = date.to_s
end

Given /^the event is happening in the past$/ do
  # this is set in eventbrite
end

Given /^that event is not live$/ do
  @events.last['live'] = false
end

Given /^I have signed up for (#{INTEGER}) tickets? called "(.*?)" which has a net price of (#{FLOAT})$/ do |count, name, price|
  @quantity    = count
  @ticket_type = name
  @net_price   = price
end

Given /^the gross price of the event in Eventbrite is (#{FLOAT})$/ do |price|
  @gross_price = price
end

Given /^that event has a url '(.*?)'$/ do |url|
  @events.last['url'] = url
end

Given /^that event starts at (#{DATETIME})$/ do |datetime|
  @events.last['starts_at'] = datetime.to_s
end

Given /^that event ends at (#{DATETIME})$/ do |datetime|
  @events.last['ends_at'] = datetime.to_s
end

Given /^that event is being held at '(.*?)'$/ do |location|
  @events.last['location'] = location
end

Given /^that event has (#{INTEGER}) tickets called "(.*?)" which cost ([A-Z]{3}) (#{FLOAT})$/ do |tickets, name, currency, price|
  @events.last['ticket_types'] ||= []
  @events.last['ticket_types'] << {
    'remaining' => tickets,
    'name'      => name,
    'price'     => price,
    'currency'  => currency
  }
end

Given /^that ticket type is on sale from (#{DATETIME})$/ do |datetime|
  @events.last['ticket_types'].last['starts_at'] = datetime.to_s
end

Given /^that ticket type is on sale until (#{DATETIME})$/ do |datetime|
  @events.last['ticket_types'].last['ends_at'] = datetime.to_s
end

Then /^the net price of the event is (#{FLOAT})$/ do |price|
  @net_price = price
end

# Registration

Given /^I have registered for a ticket$/ do
  @quantity = 1
end

Given /^I have registered for two tickets$/ do
  @quantity = 2
end

Given /^that event has not sold any tickets$/ do
  # nothing to check here, we rely on the cassette or the remote API being correct. Probably a bit lame
end

Then /^no errors should be raised$/ do
  # Errors will be raised in the previous step, so we don't need to check explicitly here
end