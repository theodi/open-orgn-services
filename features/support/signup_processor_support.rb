module SignupProcessorSupport

  def create_signup_processor_membership_hash
    member_details =  {
      :level                 => @level,
      :organisation_name     => @organisation_name,
      :contact_name          => @contact_name,
      :email                 => @invoice_email,
      :phone                 => @invoice_phone, 
      :address_line1         => @invoice_address_line1, 
      :address_line2         => @invoice_address_line2, 
      :address_city          => @invoice_address_city, 
      :address_region        => @invoice_address_region, 
      :address_country       => @invoice_address_country, 
      :address_postcode      => @invoice_address_postcode, 
      :tax_number            => @tax_number, 
      :purchase_order_number => @purchase_order_number,
      :membership_number     => @membership_number
    }    
  end

end

World(SignupProcessorSupport)