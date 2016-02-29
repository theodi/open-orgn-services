module SignupProcessorSupport

  def create_signup_processor_membership_hash
    # values defined in the step definitions and should be tidied up
    organization = {
      'name'           => @company,
      'vat_id'         => @tax_registration_number,
      'company_number' => @company_number,
      'size'           => @size,
      'type'           => @type,
      'sector'         => @sector
    }
    contact_person = {
      'name'      => @name,
      'email'     => @email,
      'telephone' => @phone
      }
    billing = {
      'name'      => @name,
      'email'     => @invoice_email,
      'telephone' => @invoice_phone,
      'address'   => {
        'street_address'   => @invoice_address_line1,
        'address_locality' => @invoice_address_city,
        'address_region'   => @invoice_address_region,
        'address_country'  => @invoice_address_country,
        'postal_code'      => @invoice_address_postcode
      }
    }
    purchase = {
      'payment_method'           => @payment_method,
      'payment_freq'             => @payment_freq,
      'payment_ref'              => @payment_ref,
      'offer_category'           => @membership_level,
      'purchase_order_reference' => @purchase_order_reference,
      'membership_id'            => @membership_id,
      'discount'                 => @discount,
      'amount_paid'              => @amount_paid
    }
    [organization, contact_person, billing, purchase]
  end

end

World(SignupProcessorSupport)
