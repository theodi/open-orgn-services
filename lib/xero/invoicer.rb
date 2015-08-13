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
  #                   'payment_method'           => Payment method; 'paypal', 'credit_card', 'direct_debit', or 'invoice'
  #                   'payment_ref'              => Payment reference if available
  #                   'quantity'                 => number of tickets
  #                   'base_price'               => net price
  #                   'purchase_order_number'    => PO number for reference
  #                   'due_date'                 => Date the invoice is due
  #                   'repeat'                   => How often to repeat invoice. Currently ignored, as not supported by Xero API.
  #                                                 See https://xero.uservoice.com/forums/5528-xero-core-api/suggestions/2257421-repeating-invoices-via-the-api
  #                   'sector'                   => User's sector (optional)
  #
  # invoice_uid       - a string with a unique identifier for the invoice to be raised (optional)
  #
  # Examples
  #
  #   Invoicer.perform({:email => 'james.smith@theodi.org', ...}, {:base_price => 0.66, ...})
  #   # => nil
  #
  # Returns nil.
  def self.perform(invoice_to, invoice_details, invoice_uid = nil)
    unless invoice_sent?(invoice_uid)
      # Find appropriate contact in Xero
      contact = xero.Contact.all(:where => %{Name.ToLower() == "#{contact_name(invoice_to).downcase}"}).first
      # Create contact if it doesn't exist, otherwise invoice them.
      # Create contact will requeue this invoicing request.
      if contact.nil?
        create_contact(invoice_to)
        Resque.enqueue Invoicer, invoice_to, invoice_details, invoice_uid
      else
        invoice_contact(contact, invoice_to, invoice_details, invoice_uid)
      end
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

  def self.invoice_contact(contact, invoice_to, invoice_details, invoice_uid = nil)
    # Check existing invoices for order number
    invoices = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{contact.id}")})
    existing = invoices.find do |invoice|
      invoice.line_items.find do |line|
        line.description == invoice_details['description']
      end
    end
    unless existing
      line_items = []
      invoice_details['line_items'].each do |line_item|
        line_items << {
          description:  line_item['description'],
          unit_amount:  line_item['base_price'],
          tax_type:     invoice_to['vat_id'] ? 'NONE' : 'OUTPUT2',
          discount_rate: line_item['discount_rate']
        }
      end

      if invoice_details['payment_method'] != 'invoice'
        payment_item = {
          quantity: 0,
          unit_amount: 0,
        }
        case invoice_details['payment_method']
        when 'paypal'
          payment_item[:description] = 'PAID WITH PAYPAL'
        when 'credit_card'
          payment_item[:description] = "PAID WITH CREDIT CARD; reference #{invoice_details['payment_ref']}"
        when 'direct_debit'
          payment_item[:description] = "PAID BY DIRECT DEBIT; reference #{invoice_details['payment_ref']}"
        end
        line_items << payment_item
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
      # Set redis state to show the invoice has been sent
      remember_invoice(invoice_uid)
    else
      # If the invoice has already been raised, set the state anyway - so existing invoices without a uid don't get rechecked
      remember_invoice(invoice_uid)
    end
  end

  def self.contact_name(invoice_to)
    name = invoice_to['name']
    if name.nil? || name.blank?
      name = [invoice_to['contact_point']['name'], "(#{invoice_to['contact_point']['email']})"].join(' ').squeeze(' ')
    end
    name.strip
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

  def self.remember_invoice(key)
    Resque.redis.set(key, true) unless key.nil?
  end

  def self.invoice_sent?(key)
    if key.nil?
      false
    else
      Resque.redis.get(key).present?
    end
  end

end
