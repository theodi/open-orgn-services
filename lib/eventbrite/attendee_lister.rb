class AttendeeLister

  @queue = :invoicing

  # Public: Inspect the list of attendees for an event
  #
  # event_detais - a hash containing the details of the event from Eventbrite
  #                :id - the eventbrite ID
  #                :title - the title of the event
  #                :date - the start date of the event 
  #
  # Examples
  #
  #   AttendeeLister.perform(123456789)
  #   # => nil
  #
  # Returns nil. Queues further jobs to handle invoice raising.
  def self.perform(event_details)
    e = EventbriteClient.new ({ :app_key => ENV["EVENTBRITE_API_KEY"], :user_key => ENV["EVENTBRITE_USER_KEY"]})
    begin
      response = e.event_list_attendees(id: event_details['id'], page: 0)
    rescue RuntimeError
      response = nil
    end
    if response
      attendees = response.parsed_response['attendees']
      orders = attendees.group_by{|x| x['attendee']['order_id']}
      orders.each_pair do |order_id, attendees|
        a = attendees.first['attendee']
        if a['amount_paid'].to_f > 0
          Resque.enqueue(AttendeeInvoicer, 
            {
              'company'                  => a['company'],
              'first_name'               => a['first_name'],
              'last_name'                => a['last_name'],
              'email'                    => a['email'],
              'invoice_email'            => custom_answer(a, 'Billing Email'),
              'phone'                    => a['cell_phone'],
              'invoice_phone'            => custom_answer(a, 'Billing Phone Number'),
              'address_line1'            => a['ship_address'],
              'address_line2'            => a['ship_address_2'],
              'address_city'             => a['ship_city'],
              'address_region'           => a['ship_region'],
              'address_country'          => a['ship_country'],
              'address_postcode'         => a['ship_postal_code'],
              'invoice_address_line1'    => custom_answer(a, 'Billing Address (line 1)'),
              'invoice_address_line2'    => custom_answer(a, 'Billing Address (line 2)'),
              'invoice_address_city'     => custom_answer(a, 'Billing Address (city)'),
              'invoice_address_region'   => custom_answer(a, 'Billing Address (region)'),
              'invoice_address_country'  => custom_answer(a, 'Billing Address (country)'),
              'invoice_address_postcode' => custom_answer(a, 'Billing Address (postcode)'),
              'vat_number'               => custom_answer(a, 'VAT reg number (if non-UK)'),
            }.compact, 
            event_details, 
            {
              'payment_method'        => payment_method(a['order_type']),
              'quantity'              => attendees.count,
              'price'                 => a['amount_paid'].to_f/1.2,
              'order_number'          => order_id,
              'membership_number'     => custom_answer(a, 'Membership Number'),
              'purchase_order_number' => custom_answer(a, 'Purchase Order Number'),

            }.compact
          )
        end
      end
    end
  end
  
  def self.custom_answer(attendee, question)
    q = attendee['answers'].find{|x| x['answer']['question'] == question}
    q ? q['answer']['answer_text'] : nil
  end

  def self.payment_method(order_type)
    case order_type.downcase
    when /paypal/
      'paypal'
    when /invoice/
      'invoice'
    else
      nil
    end
  end
  
end