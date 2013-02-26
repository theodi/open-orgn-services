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

  # user_details    - a hash containing details of the user.
  #                   'company'                  => Company name
  #                   'first_name'               => First name of main attendee
  #                   'last_name'                => Last name of main attendee
  #                   'invoice_email'            => Email address for invoicing
  #                   'invoice_phone'            => Phone number for invoicing
  #                   'invoice_address_line1'    => Address for invoicing
  #                   'invoice_address_line2'    => Address for invoicing
  #                   'invoice_address_city'     => Address for invoicing
  #                   'invoice_address_region'   => Address for invoicing
  #                   'invoice_address_country'  => Address for invoicing
  #                   'invoice_address_postcode' => Address for invoicing
  #                   'tax_number'               => Tax number for overseas customers
  #                   'membership_number'        => ODI membership number

  # payment_details - a hash containing payment details.
  #                   'payment_method'           => Payment method; 'paypal', or 'invoice'
  #                   'quantity'                 => number of things
  #                   'base_price'               => ie the price before VAT
  #                   'order_number'             => unique order number
  #                   'purchase_order_number'    => PO number for reference

  user_details = {
    :company                  => @company_name,
    :contact_name             => @contact_name,
    :invoice_email            => @invoice_email,
    :invoice_phone            => @invoice_phone,
    :invoice_address_line1    => @invoice_address_line1,
    :invoice_address_line2    => @invoice_address_line2,
    :invoice_address_city     => @invoice_address_city,
    :invoice_address_region   => @invoice_address_region,
    :invoice_address_country  => @invoice_address_country,
    :invoice_address_postcode => @invoice_address_postcode,
    :tax_number               => @tax_number,
    :membership_number        => @membership_number
  }

  invoice_details = {
    :payment_method           => @payment_method,
    :quantity                 => @quantity,
    :base_price               => @base_price,
    :order_number             => @order_number,
    :purchase_order_number    => @purchase_order_number,
    :invoice_description      => @invoice_description
  }

  # Set expectation
  Resque.should_receive(:enqueue).with(Invoicer, user_details, invoice_details).once
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