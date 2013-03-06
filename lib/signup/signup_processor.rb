class SignupProcessor
  @queue = :signup
  
  # Public: Process new signups from the member site
  #
  # expects input of the following form...
  #
  # organization      - a hash containing the details of the member organisation
  #                   'name'
  #                   'vat_id'
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
  #                   'offer_category'
  #                   'purchase_order_reference'
  #                   'membership_id'


  # Returns nil. Queues invoicing and CRM task creation jobs.


  def self.base_price(offer_category)
    # get the base price for this level of membership
    case offer_category
    when 'supporter'
      45
    when 'member'
      400
    else
      raise ArgumentError.new("Member level is invalid")
    end
  end

  def self.description(membership_id, offer_category)
      "ODI #{offer_category.capitalize} Membership (#{membership_id})"
  end


  def self.perform(organization, contact_person, billing, purchase)

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
      'quantity' => 1,
      'base_price' => base_price(purchase['offer_category']),
      'purchase_order_reference' => purchase['purchase_order_reference'],
      'description' => description(purchase['membership_id'], purchase['offer_category'])
    }
    Resque.enqueue(Invoicer, invoice_to, invoice_details)
    
    # Save details in capsule
    
    organization = {
      'name' => organization['name']
    }
    membership = {
      'product_name' => purchase['offer_category'],
      'number'       => purchase['membership_id'].to_s,
      'join_date'    => Date.today.to_s,
    }
    Resque.enqueue(SendSignupToCapsule, organization, membership)
  end
  
end