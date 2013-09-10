module InvoicerSupport
  
  # Utility functions to marshal setup variables into appropriate hashes

  def create_invoice_to_hash
    {
      'name'               => @company,
      'contact_point'      => {
        'name'             => @name || @first_name + " " + @last_name,
        'email'            => @invoice_email,
        'telephone'        => @invoice_phone,
        }.compact,
      'address'            => {
        'street_address'   => @invoice_address_line1 || @invoice_address_line2 ? [@invoice_address_line1, @invoice_address_line2].compact.join(", ") : nil,
        'address_locality' => @invoice_address_city,
        'address_region'   => @invoice_address_region,
        'address_country'  => @invoice_address_country,
        'postal_code'      => @invoice_address_postcode
      }.compact,
      'vat_id'             => @tax_registration_number
      
    }.compact
  end
  
  def create_invoice_details_hash
    {
      'payment_method'           => @payment_method,
      'quantity'                 => @quantity,
      'base_price'               => @base_price,
      'purchase_order_reference' => @purchase_order_reference,
      'description'              => @invoice_description,
      'due_date'                 => @invoice_due_date ? @invoice_due_date.to_s : nil

    }.compact    
  end
  
  def create_redis_key
    if @order_number
      event_id = @events.first['id'] rescue 1234567
      "eventbrite-#{event_id}-#{@order_number}-invoice-sent"
    else
      nil
    end
  end

end

World(InvoicerSupport)