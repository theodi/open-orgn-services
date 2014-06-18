class SignupProcessor
  @queue = :signup

  # Public: Process new signups from the member site
  #
  # expects input of the following form...
  #
  # organization      - a hash containing the details of the member organisation
  #                   'name'
  #                   'vat_id'
  #                   'company_number'
  #                   'size'
  #                   'type'
  #
  # contact_person    - a hash containing details of the main contact for the member organisation
  #                    'name'
  #                    'email'
  #                    'telephone'
  #
  # billing           - a hash containing the details of the billing contact for the member organisation
  #                   'name'
  #                   'email'
  #                   'telephone'
  #                   'address' => {
  #                      'street_address' => ...,
  #                      'address_locality',
  #                      'address_region',
  #                      'address_country',
  #                      'postal_code'
  #                    }
  #
  # purchase          - a hash containing information about the purchase
  #                   'payment_method'
  #                   'payment_freq'
  #                   'payment_ref'
  #                   'offer_category'
  #                   'purchase_order_reference'
  #                   'membership_id'


  # Returns nil. Queues invoicing and CRM task creation jobs.


  def self.membership_type(size, type)
    if size == "small" || type == "non_commercial"
      {
        price: (60 * 12),
        description: "Supporter",
        type: "Supporter"
      }
    else
      {
        price: (120 * 12),
        description: "Corporate Supporter",
        type: "Corporate supporter"
      }
    end
  end

  def self.description(membership_id, description, type)
      "ODI #{description} (#{membership_id}) [#{type.titleize}]"
  end


  def self.perform(organization, contact_person, billing, purchase)
    membership_type = membership_type(organization['size'], organization['type'])

    invoice_to = {
      'name' => organization['name'],
      'contact_point' => {
        'name' => billing['name'],
        'email' => billing['email'],
        'telephone' => billing['telephone'],
      },
      'address' => {
        'street_address' => billing['address']['street_address'],
        'address_locality' => billing['address']['address_locality'],
        'address_region' => billing['address']['address_region'],
        'address_country' => billing['address']['address_country'],
        'postal_code' => billing['address']['postal_code']
      },
      'vat_id' => organization['vat_id']
    }
    invoice_details = {
      'payment_method' => purchase['payment_method'],
      'payment_freq' => purchase['payment_freq'],
      'payment_ref' => purchase['payment_ref'],
      'quantity' => 1,
      'base_price' => membership_type[:price],
      'purchase_order_reference' => purchase['purchase_order_reference'],
      'description' => description(purchase['membership_id'],
                                   membership_type[:description],
                                   organization['type']
                                  )
    }.compact
    Resque.enqueue(Invoicer, invoice_to, invoice_details)

    # Save details in capsule

    organization = {
      'name' => organization['name'],
      'company_number' => organization['company_number']
    }
    membership = {
      'product_name'    => purchase['offer_category'],
      'supporter_level' => membership_type[:type],
      'id'              => purchase['membership_id'].to_s,
      'join_date'       => Date.today.to_s,
      'contact_email'   => contact_person['email']
    }
    Resque.enqueue(SendSignupToCapsule, organization, membership)
  end

end
