class SignupProcessor
  @queue = :signup
  
  # Public: Process new signups from the member site
  #
  # user_details    - a hash containing details of the newly signed-up user.
  #                   'level'                 => Membership level
  #                   'organisation_name'     => Name or organisation
  #                   'contact_name'          => Name of contact
  #                   'email'                 => Email address of contact
  #                   'phone'                 => Phone number of contact 
  #                   'address_line1'         => Address
  #                   'address_line2'         => Address
  #                   'address_city'          => Address
  #                   'address_region'        => Address
  #                   'address_country'       => Address
  #                   'address_postcode'      => Address
  #                   'tax_number'            => Tax number for overseas customers 
  #                   'purchase_order_number' => PO number if supplied
  #                   'membership_number'        => New membership number
  # 
  #
  # Examples
  #
  #   SignupProcessor.perform({:organisation_name => 'New Company Inc.', ...})
  #   # => nil
  #
  # Returns nil. Queues invoicing and CRM task creation jobs.

  def self.perform(user_details)
  end
  
end