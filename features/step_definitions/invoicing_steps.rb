When(/^the invoicer runs$/) do
  # Set some things that must exist, if they don't already
  @invoice_description ||= SecureRandom.hex(32)
  @base_price ||= SecureRandom.random_number(9999)
  @invoice_uid ||= create_invoice_uid

  # Invoice
  Invoicer.perform(create_invoice_to_hash, create_invoice_details_hash, @invoice_uid)
end

Given(/^I have made a purchase$/) do
  @line_items = [
    {
      'base_price'  => "1.00",
      'description' => "Line Item Number 0"
    }
  ]
end

Given(/^my purchase has a line item type of "(.*?)"$/) do |type|
  @line_amount_types = type
end

Given(/^I have purchased two items$/) do
  @line_items = [
    {
      'base_price'  => "1.00",
      'description' => "Line Item Number 1"
    },
    {
      'base_price'  => "1.00",
      'description' => "Line Item Number 2"
    }
  ]
end
