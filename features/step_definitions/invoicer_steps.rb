# Invoice queue

When /^the attendee invoicer runs$/ do
  # Invoice
  Invoicer.perform(create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash)
end

Then /^I should be added to the invoicing queue$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash).once
  Resque.should_receive(:enqueue).any_number_of_times
end


## for new style invoicing queue
Then /^I should be added to the new style invoicing queue$/ do
  
  invoice_to = {
    'name' => @company,
    'contact_point' => {
      'name' => @name,
      'email' => @invoice_email,
      'telephone' => @invoice_phone,
    },
    'address' => {
      'street_address' => @invoice_address_line1,
      'address_locality' => @invoice_address_city,
      'address_region' => @invoice_address_region,
      'address_country' => @invoice_address_country,
      'postal_code' => @invoice_address_postcode
    },
    'vat_id' => @tax_registration_number
  }
  
  invoice_details = {
    'quantity' => 1,
    'base_price' => @base_price,
    'purchase_order_reference' => @purchase_order_reference,
    'description' => @invoice_description
  }

  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, invoice_to, invoice_details).once
end
## for new style invoicing queue


Then /^I should not be added to the invoicing queue$/ do
  Resque.should_not_receive(:enqueue).with do |klass, user, event, payment|
    payment[:order_number] == @order_number
  end
end

Then /^the attendee invoicer should be requeued$/ do
  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, create_invoicer_user_hash, create_invoicer_event_hash, create_invoicer_payment_hash)
end