require 'date'

class Invoicer

  @queue = :invoicing

  # Public: Create an invoice for an event attendee
  #
  # user_details    - a hash containing details of the user.
  #                   'company'                  => Company name
  #                   'first_name'               => First name of main attendee
  #                   'last_name'                => Last name of main attendee
  #                   'email'                    => Email address of main attendee
  #                   'invoice_email'            => Email address for invoicing
  #                   'phone'                    => Phone number of main attendee
  #                   'invoice_phone'            => Phone number for invoicing
  #                   'address_line1'            => Address for delivery (i.e. not billing)
  #                   'address_line2'            => Address for delivery (i.e. not billing)
  #                   'address_city'             => Address for delivery (i.e. not billing)
  #                   'address_region'           => Address for delivery (i.e. not billing)
  #                   'address_country'          => Address for delivery (i.e. not billing)
  #                   'address_postcode'         => Address for delivery (i.e. not billing)
  #                   'invoice_address_line1'    => Address for invoicing
  #                   'invoice_address_line2'    => Address for invoicing
  #                   'invoice_address_city'     => Address for invoicing
  #                   'invoice_address_region'   => Address for invoicing
  #                   'invoice_address_country'  => Address for invoicing
  #                   'invoice_address_postcode' => Address for invoicing
  #                   'tax_number'               => Tax number for overseas customers
  # payment_details - a hash containing payment details.
  #                   'payment_method'           => Payment method; 'paypal', or 'invoice'
  #                   'quantity'                 => number of tickets
  #                   'price'                    => net price
  #                   'order_number'             => unique order number from eventbrite
  #                   'membership_number'        => ODI membership number
  #                   'purchase_order_number'    => PO number for reference
  #                   'due_date'                 => Date the invoice is due
  

  # def create_invoice_to_hash
  #   {
  #     'name'               => @company,
  #     'contact_point'      => {
  #       'name'             => @name || @first_name + " " + @last_name,
  #       'email'            => @invoice_email,
  #       'telephone'        => @invoice_phone,
  #       }.compact,
  #     'address'            => {
  #       'street_address'   => @invoice_address_line1 || @invoice_address_line2 ? [@invoice_address_line1, @invoice_address_line2].compact.join(", ") : nil,
  #       'address_locality' => @invoice_address_city,
  #       'address_region'   => @invoice_address_region,
  #       'address_country'  => @invoice_address_country,
  #       'postal_code'      => @invoice_address_postcode
  #     }.compact,
  #     'vat_id'             => @tax_registration_number
  #     
  #   }.compact
  # end
  # 
  # def create_invoice_details_hash
  #   {
  #     'payment_method'           => @payment_method,
  #     'quantity'                 => @quantity,
  #     'base_price'               => @base_price,
  #     'purchase_order_reference' => @purchase_order_reference,
  #     'description'              => @invoice_description,
  #     'due_date'                 => @invoice_due_date ? @invoice_due_date.to_s : nil
  # 
  #   }.compact    
  # end
  
  #
  # Examples
  #
  #   Invoicer.perform({:email => 'james.smith@theodi.org', ...}, {:id => 123456789, ...}, {:price => 0.66, ...})
  #   # => nil
  #
  # Returns nil.
  def self.perform(invoice_to, invoice_details)
    # Find appropriate contact in Xero
    contact = xero.Contact.all(:where => %{Name == "#{contact_name(invoice_to)}"}).first
    # Create contact if it doesn't exist, otherwise invoice them. 
    # Create contact will requeue this invoicing request.
    if contact.nil?
      create_contact(invoice_to)
      Resque.enqueue Invoicer, invoice_to, invoice_details
    else
      invoice_contact(contact, user_details, payment_details)
    end
  end

  def self.create_contact(invoice_to)
    addresses = []
    # Billing address
    addresses << {
      type: 'POBOX',
      line1:       invoice_to['address']['street_address'] ,
      city:        invoice_to['address']['address_locality'],
      region:      invoice_to['address']['address_region'],
      country:     invoice_to['address']['address_country'],
      postal_code: invoice_to['address']['postal_code'],
    }
    # Create contact
    contact = xero.Contact.create(
      name:          contact_name(invoice_to),
      email_address: invoice_to['contact_point']['email'],
      phones:        [{type: 'DEFAULT', number: invoice_to['contact_point']['telephone']}],
      addresses:     addresses,
      tax_number:    invoice_to['vat_id'],
    )
    contact.save    
  end
  
  def self.invoice_contact(contact, user_details, payment_details)
    # Check existing invoices for order number
    invoices = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{contact.id}") AND Status != "DELETED"})
    existing = invoices.find do |invoice| 
      invoice.line_items.find do |line| 
        line.description =~ /Order number: #{payment_details['order_number']}/
      end
    end
    unless existing
      # Raise invoice
      line_items = [{
        description:  payment_details['invoice_description'],
        quantity:     payment_details['quantity'], 
        unit_amount:  payment_details['price'],
        tax_type:     user_details['tax_number'] ? 'NONE' : 'OUTPUT2'
      }]
      # Add an empty line item for Paypal payment if appropriate
      if payment_details['payment_method'] == 'paypal'
        line_items << {description: "PAID WITH PAYPAL", quantity: 0, unit_amount: 0}
      end
      
      # Create invoice
      invoice = xero.Invoice.create(
        type:       'ACCREC',
        contact:    contact,
        due_date:   payment_details['due_date'] || Date.today,
        status:     'DRAFT',
        line_items: line_items,
        reference:  payment_details['purchase_order_number'],
      )
      invoice.save
    end
  end

  def self.contact_name(invoice_to)
    invoice_to['name'] || [invoice_to['contact_point']['name'], "<#{invoice_to['contact_point']['email']}>"].join(' ')
  end

  def self.xero
    # Connect to Xero
    @@xero ||= Xeroizer::PrivateApplication.new(
      ENV["XERO_CONSUMER_KEY"],
      ENV["XERO_CONSUMER_SECRET"],
      ENV["XERO_PRIVATE_KEY_PATH"],
      :rate_limit_sleep => 5
    )
  end

end