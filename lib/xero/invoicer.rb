require 'date'

class Invoicer

  @queue = :invoicing

  # Public: Create an invoice for an event attendee
  #
  # invoice_to         - a hash containing details of the user.
  #                   'name'          => Company name
  #
  #                   'contact_point' - A hash containing contact details of the point of contact for the invoice
  #                                   'name'      => Contact name
  #                                   'email'     => Email address
  #                                   'telephone' => Telephone number
  #
  #                   'address'       - A hash containing the address
  #                                   'street_address'   => Street address,
  #                                   'address_locality' => Locality / city,
  #                                   'address_region'   => Region,
  #                                   'address_country'  => Country,
  #                                   'postal_code'      => Postcode
  #
  #                   'vat_id'        => Tax number for overseas customers
  # invoice_details   - a hash containing payment details.
  #                   'payment_method'           => Payment method; 'paypal', or 'invoice'
  #                   'quantity'                 => number of tickets
  #                   'base_price'                    => net price
  #                   'purchase_order_number'    => PO number for reference
  #                   'due_date'                 => Date the invoice is due  
  #
  # Examples
  #
  #   Invoicer.perform({:email => 'james.smith@theodi.org', ...}, {:base_price => 0.66, ...})
  #   # => nil
  #
  # Returns nil.
  def self.perform(invoice_to, invoice_details)
    # Find appropriate contact in Xero
    contact = xero.Contact.all(:where => %{Name.ToLower() == "#{contact_name(invoice_to).downcase}"}).first
    # Create contact if it doesn't exist, otherwise invoice them. 
    # Create contact will requeue this invoicing request.
    if contact.nil?
      create_contact(invoice_to)
      Resque.enqueue Invoicer, invoice_to, invoice_details
    else
      invoice_contact(contact, invoice_to, invoice_details)
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
  
  def self.invoice_contact(contact, invoice_to, invoice_details)
    # Check existing invoices for order number
    invoices = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{contact.id}")})
    existing = invoices.find do |invoice| 
      invoice.line_items.find do |line| 
        line.description == invoice_details['description']
      end
    end
    unless existing
      # Raise invoice
      line_items = [{
        description:  invoice_details['description'],
        quantity:     invoice_details['quantity'], 
        unit_amount:  invoice_details['base_price'],
        tax_type:     invoice_to['vat_id'] ? 'NONE' : 'OUTPUT2'
      }]
      # Add an empty line item for Paypal payment if appropriate
      if invoice_details['payment_method'] == 'paypal'
        line_items << {description: "PAID WITH PAYPAL", quantity: 0, unit_amount: 0}
      end
      
      # Create invoice
      invoice = xero.Invoice.create(
        type:       'ACCREC',
        contact:    contact,
        due_date:   invoice_details['due_date'] ? Date.parse(invoice_details['due_date']) : Date.today,
        status:     'DRAFT',
        line_items: line_items,
        reference:  invoice_details['purchase_order_reference'],
      )
      invoice.save
    end
  end

  def self.contact_name(invoice_to)
    name = invoice_to['name']
    if name.nil? || name.blank?
      name = [invoice_to['contact_point']['name'], "<#{invoice_to['contact_point']['email']}>"].join(' ')
    end
    name
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