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

  user_details = {
    :contact_name             => @name,
    :contact_email            => @email,                      # do we need this still at the invoice stage?
    :organisation             => @company,
    :invoice_email            => @invoice_email,
    :invoice_phone            => @invoice_phone,              # can we expect the person registering to know the invoice phone?
    :invoice_address_line1    => @invoice_address_line1,
    :invoice_address_line2    => @invoice_address_line2,
    :invoice_address_city     => @invoice_address_city,
    :invoice_address_region   => @invoice_address_region,
    :invoice_address_country  => @invoice_address_country,
    :invoice_address_postcode => @invoice_address_postcode,
    :tax_registration_number  => @tax_registration_number,
    :membership_number        => @membership_number
  }

  invoice_details = {
    :payment_method           => @payment_method,
    :quantity                 => @quantity,
    :base_price               => @base_price,
    :purchase_order_reference => @purchase_order_reference,
    :invoice_description      => @invoice_description
  }

  # Set expectation
  #Resque.should_receive(:enqueue).with(Invoicer, user_details, invoice_details).once
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