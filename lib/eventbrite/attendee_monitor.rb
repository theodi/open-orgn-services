class AttendeeMonitor

  @queue = :invoicing

  # Public: Inspect the list of attendees for an event
  #
  # event_details - a hash containing the details of the event from Eventbrite. Required keys are:
  #                 'id'        - the unique identifier supplied from Eventbrite
  #                 'title'     - the event name
  #                 'starts_at' - the starting DateTime of the event
  #
  # Examples
  #
  #   AttendeeMonitor.perform('id' => 1235, 'title' => 'Open Data for Dummies', 'starts_at' => Date.new(2013,3,1))
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
          
          date = Date.parse(event_details['starts_at']) rescue nil
          
          invoice_to = {
            'name'               => a['company'],
            'contact_point'      => {
              'name'             => a['first_name'] + " " + a['last_name'],
              'email'            => custom_answer(a, 'Billing Email'),
              'telephone'        => custom_answer(a, 'Billing Phone Number'),
            },
            'address'            => {
              'street_address'   => [custom_answer(a, 'Billing Address (line 1)'), custom_answer(a, 'Billing Address (line 2)')].join(", "),
              'address_locality' => custom_answer(a, 'Billing Address (city)'),
              'address_region'   => custom_answer(a, 'Billing Address (region)'),
              'address_country'  => custom_answer(a, 'Billing Address (country)'),
              'postal_code'      => custom_answer(a, 'Billing Address (postcode)')
            },
            'vat_id'             => custom_answer(a, 'VAT reg number (if non-UK)')
      
          }          
          
          invoice_details =  {
            'payment_method'           => payment_method(a['order_type']),
            'quantity'                 => attendees.count,
            'base_price'               => a['amount_paid'].to_f/1.2,
            'purchase_order_reference' => custom_answer(a, 'Purchase Order Number'),
            'description'              => description(event_details['title'], date, a['first_name'], a['last_name'], a['email'], order_id, custom_answer(a, 'Membership Number')),
            'due_date'                 => (date ? date - 7 : Date.today).to_s
      
          }        
          
          Resque.enqueue(Invoicer, invoice_to, invoice_details)
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
  
  def self.description(title, date, first_name, last_name, email, order_number, membership_number)
    description = "Registration for '#{title} (#{date})' for #{first_name} #{last_name} <#{email}> ("
    description += "Order number: #{order_number}" if order_number
    description += ",Membership number: #{membership_number}" if membership_number
    description += ")"
  end
  
end