require 'date'

class AttendeeInvoicer

  @queue = :invoicing

  # Public: Create an invoice for an event attendee
  #
  # user_details    - a hash containing details of the user.
  #                   :email - the user's email address
  # event_details   - a hash containing the details of the event.
  #                   :id - the eventbrite ID
  # payment_details - a hash containing payment details.
  #                   :amount - The monetary amount to be invoiced in GBP
  #
  # Examples
  #
  #   AttendeeInvoicer.perform({:email => 'james.smith@theodi.org'}, {:id => 123456789}, {:amount => 0.66})
  #   # => nil
  #
  # Returns nil.
  def self.perform(user_details, event_details, payment_details)
    # Find appropriate contact in Xero
    contact = xero.Contact.all(:where => %{Name == "#{contact_name(user_details)}"}).first
    # Create contact if it doesn't exist, otherwise invoice them. 
    # Create contact will requeue this invoicing request.
    if contact.nil?
      create_contact(user_details, event_details, payment_details)
    else
      invoice_contact(contact, user_details, event_details, payment_details)
    end
  end

  def self.create_contact(user_details, event_details, payment_details)
    addresses = []
    # Billing address
    addresses << {
      type: 'POBOX',
      line1:       user_details['invoice_address_line1']    || user_details['address_line1'],
      line2:       user_details['invoice_address_line2']    || user_details['address_line2'],
      city:        user_details['invoice_address_city']     || user_details['address_city'],
      region:      user_details['invoice_address_region']   || user_details['address_region'],
      country:     user_details['invoice_address_country']  || user_details['address_country'],
      postal_code: user_details['invoice_address_postcode'] || user_details['address_postcode'],
    }
    # Create contact
    contact = xero.Contact.create(
      name:          contact_name(user_details),
      email_address: user_details['invoice_email'] || user_details['email'],
      phones:        [{type: 'DEFAULT', number: user_details['invoice_phone'] || user_details['phone']}],
      addresses:     addresses,
      tax_number:    user_details['vat_number'],
    )
    contact.save
    # Requeue
    Resque.enqueue AttendeeInvoicer, user_details, event_details, payment_details
  end
  
  def self.invoice_contact(contact, user_details, event_details, payment_details)
    # Check existing invoices for order number
    invoices = xero.Invoice.all(:where => %{Contact.ContactID = GUID("#{contact.id}") AND Status != "DELETED"})
    existing = invoices.find do |invoice| 
      invoice.line_items.find do |line| 
        line.description =~ /Order number: #{payment_details['order_number']}/
      end
    end
    unless existing
      # Build description
      description = "Registration for '#{event_details['title']} (#{event_details['date']})' for #{user_details['first_name']} #{user_details['last_name']} <#{user_details['email']}> ("
      description += "Order number: #{payment_details['order_number']}" if payment_details['order_number']
      description += ",Membership number: #{payment_details['membership_number']}" if payment_details['membership_number']
      description += ")"
      # Raise invoice
      line_items = [{
        description:  description,
        quantity:     payment_details['quantity'], 
        unit_amount:  payment_details['price'],
        tax_type:     user_details['vat_number'] ? 'NONE' : 'OUTPUT2'
      }]
      # Add an empty line item for Paypal payment if appropriate
      if payment_details['payment_method'] == 'paypal'
        line_items << {description: "PAID WITH PAYPAL", quantity: 0, unit_amount: 0}
      end
      # Create invoice
      invoice = xero.Invoice.create(
        type:       'ACCREC',
        contact:    contact,
        due_date:   (event_details['date'] ? event_details['date'] - 7 : Date.today),
        status:     'DRAFT',
        line_items: line_items,
        reference:  payment_details['purchase_order_number'],
      )
      invoice.save
    end
  end

  def self.contact_name(user_details)
    user_details['company'] || [user_details['first_name'], user_details['last_name'], "<#{user_details['email']}>"].join(' ')
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