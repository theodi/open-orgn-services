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
    # Connect to Xero
    @@xero ||= Xeroizer::PrivateApplication.new(
      ENV["XERO_CONSUMER_KEY"],
      ENV["XERO_CONSUMER_SECRET"],
      ENV["XERO_PRIVATE_KEY_PATH"],
      :rate_limit_sleep => 5
    )
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
      line1:       user_details[:invoice_address_line1]    || user_details[:address_line1],
      city:        user_details[:invoice_address_city]     || user_details[:address_city],
      country:     user_details[:invoice_address_country]  || user_details[:address_country],
    }
    # Create contact
    contact = xero.Contact.create(
      name:          contact_name(user_details),
      email_address: user_details[:invoice_email] || user_details[:email],
      phones:        [{type: 'DEFAULT', number: user_details[:invoice_phone] || user_details[:phone]}],
      addresses:     addresses,
      tax_number:    user_details[:vat_number],
    )
    contact.save
    # Requeue
    Resque.enqueue AttendeeInvoicer, user_details, event_details, payment_details
  end
  
  def self.invoice_contact(contact, user_details, event_details, payment_details)
    # Build description
    description = "Registration for '#{event_details[:title]} (#{event_details[:date]})' for #{user_details[:first_name]} #{user_details[:last_name]} <#{user_details[:email]}> ("
    description += "Order number: #{payment_details[:order_number]}," if payment_details[:order_number]
    description += ")"
    # Raise invoice
    line_item = {
      description:  description,
      quantity:     payment_details[:quantity], 
      unit_amount:  payment_details[:price]
    }
    # Don't charge tax overseas if vat reg number supplied
    line_item[:tax_type] = "NONE" if user_details[:vat_number]
    # Create invoice
    invoice = xero.Invoice.create(
      type:       'ACCREC',
      contact:    contact,
      due_date:   (event_details[:date] ? event_details[:date] - 7 : Date.today),
      status:     'DRAFT',
      line_items: [line_item],
      reference:  payment_details[:purchase_order_number],
    )
    invoice.save
  end

  def self.contact_name(user_details)
    user_details[:company] || [user_details[:first_name], user_details[:last_name], "<#{user_details[:email]}>"].join(' ')
  end

end