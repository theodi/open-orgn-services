module InvoicerSupport
  
  # Utility functions to marshal setup variables into appropriate hashes

  def create_invoicer_user_hash
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

  def create_invoicer_event_hash
    @events ? @events.last.compact : {}
  end

  def create_invoicer_membership_hash
    @membership = { :description => "ODI " + @level + " membership " + @company.nil? ? "for " + @company : ( @firstname && @lastname ? "for " + @firstname + @lastname : "" ) }
  end

  def create_invoicer_payment_hash
    {
      'order_number'          => @order_number,
      'price'                 => @net_price,
      'quantity'              => @quantity,
      'purchase_order_number' => @purchase_order_number,
      'membership_number'     => @membership_number,
      'payment_method'        => @payment_method
    }.compact
  end

end

World(InvoicerSupport)