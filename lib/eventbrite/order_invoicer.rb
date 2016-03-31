class OrderInvoicer
  @queue = :invoicing

  def self.perform(order_uri)
    new.perform(order_uri)
  end

  def perform(order_uri)
    order = Eventbrite::Client.order_details(order_uri)
    event = order['event']
    attendees = order['attendees']
    purchaser = attendees.first
    profile = purchaser['profile']

    details = answers_map(purchaser['answers'])

    invoice_id = "eventbrite:event:#{event['id']}:invoice:#{order['id']}"
    start_date = Date.parse(event['start']['utc'])
    due_date = start_date - 7.days

    invoice_to = {
      'name'               => profile['company'],
      'contact_point'      => {
        'name'             => profile['name'],
        'email'            => details['Billing Email'],
        'telephone'        => details['Billing Phone Number'],
      },
      'address'            => {
        'street_address'   => [details['Billing Address (line 1)'], details['Billing Address (line 2)']].join(", "),
        'address_locality' => details['Billing Address (city)'],
        'address_region'   => details['Billing Address (region)'],
        'address_country'  => details['Billing Address (country)'],
        'postal_code'      => details['Billing Address (postcode)']
      },
      'vat_id'             => details['VAT reg number (if non-UK)']
    }

    ticket_classes = tickets_map(order['event']['ticket_classes'])
    line_items = attendees.map { |attendee| order_line(order, attendee, ticket_classes) }

    invoice_details =  {
      'payment_method'           => "mystery", #TODO: find out what
      'line_items'               => line_items,
      'purchase_order_reference' => details['Purchase Order Number'],
      'due_date'                 => due_date.iso8601,
      'sector'                   => details['Sector']
    }

    if line_items.count > 0
      Resque.enqueue(Invoicer, invoice_to, invoice_details, invoice_id)
    end
  end

  def order_line(order, attendee, ticket_classes)
    base_price = attendee['costs']['base_price']
    {
      'base_price' => base_price['value'],
      'description' => order_line_description(order, attendee, ticket_classes)
    }
  end

  #ticket, event_details['title'], date, a['attendee']['first_name'], a['attendee']['last_name'], a['attendee']['email'], order_id, custom_answer(a['attendee'], 'Membership Number'))
  def order_line_description(order, attendee, ticket_classes)
    ticket_name = ticket_classes[attendee['ticket_class_id']]
    event = order['event']
    title = event['name']['text']
    date = Date.parse(event['start']['utc']).iso8601
    name = attendee['profile']['name']
    email = attendee['profile']['email']

    details = answers_map(attendee['answers'])
    membership_number = details['Membership Number']
    extras = [
      "Order number: #{order['id']}",
      ("Membership number: #{membership_number}" if membership_number)
    ]

    extra_desc = extras.compact.join(", ")

    "#{ticket_name} for '#{title} (#{date})' for #{name} <#{email}> #{extra_desc}"
  end

  def answers_map(answers)
    map_hash(answers, %w[question answer])
  end

  def tickets_map(ticket_classes)
    map_hash(ticket_classes, %w[id name])
  end

  def map_hash(list, pair)
    Hash[list.map {|i| i.values_at(*pair)}]
  end
end
