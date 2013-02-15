module XeroSupport
  
  # Utility functions to marshal setup variables into appropriate hashes

  def user_details
    {
      'company'                  => @company,
      'first_name'               => @first_name,
      'last_name'                => @last_name,
      'email'                    => @email,
      'invoice_email'            => @invoice_email,
      'phone'                    => @phone,
      'invoice_phone'            => @invoice_phone,
      'address_line1'            => @address_line1,
      'address_line2'            => @address_line2,
      'address_city'             => @address_city,
      'address_region'           => @address_region,
      'address_country'          => @address_country,
      'address_postcode'         => @address_postcode,
      'invoice_address_line1'    => @invoice_address_line1,
      'invoice_address_line2'    => @invoice_address_line2,
      'invoice_address_city'     => @invoice_address_city,
      'invoice_address_region'   => @invoice_address_region,
      'invoice_address_country'  => @invoice_address_country,
      'invoice_address_postcode' => @invoice_address_postcode,
      'vat_number'               => @vat_reg_number,

    }.compact
  end

  def event_details
    @events.last.compact
  end

  def payment_details
    {
      'order_number'          => @order_number,
      'price'                 => @net_price,
      'quantity'              => @quantity,
      'purchase_order_number' => @purchase_order_number,
      'membership_number'     => @membership_number,
      'payment_method'        => @payment_method
    }.compact
  end

  # Shared setup for the Xero connection

  def xero
    @xero ||= Xeroizer::PrivateApplication.new(
      ENV["XERO_CONSUMER_KEY"],
      ENV["XERO_CONSUMER_SECRET"],
      ENV["XERO_PRIVATE_KEY_PATH"],
      :rate_limit_sleep => 5
    )
  end
  
end

World(XeroSupport)