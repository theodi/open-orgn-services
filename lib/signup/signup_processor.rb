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


  def self.base_price
    # get the base price for this level of membership
    # hardcoded for now, because
    1000
  end

  def self.description(membership_id, name)
    if name.nil?
      "ODI membership (#{membership_id})"
    else
      "ODI membership (#{membership_id}) for #{name}"
    end
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
      'base_price' => base_price,
      'purchase_order_reference' => purchase['purchase_order_reference'],
      'description' => description(purchase['membership_id'], organization['name'])
    }

    Resque.enqueue(Invoicer, invoice_to, invoice_details)
  end
  
end