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
    xero ||= Xeroizer::PrivateApplication.new(
      ENV["XERO_CONSUMER_KEY"],
      ENV["XERO_CONSUMER_SECRET"],
      ENV["XERO_PRIVATE_KEY_PATH"]
    )
    # Find appropriate contact in Xero
    contact = xero.Contact.all(:where => %{Name == "#{contact_name(user_details)}"}).first
    # Create contact if it doesn't exist, otherwise invoice them. 
    # Create contact will requeue this invoicing request.
    if contact.nil?
      create_contact(user_details, event_details, payment_details)
    else
      invoice_contact(user_details, event_details, payment_details)
    end
  end

  def self.create_contact(user_details, event_details, payment_details)
    contact = xero.Contact.create(
      name: contact_name(user_details),
      email_address: user_details[:invoice_email] || user_details[:email],
      phones: [{type: 'DEFAULT', number: user_details[:invoice_phone] || user_details[:phone]}],
    )
    contact.save
    # Requeue
    Resque.enqueue AttendeeInvoicer, user_details, event_details, payment_details
  end
  
  def self.invoice_contact(user_details, event_details, payment_details)
  end

  def self.contact_name(user_details)
    user_details[:company] || [user_details[:first_name], user_details[:last_name]].join(' ')
  end

end