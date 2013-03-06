require 'pry'

class SendSignupToCapsule
  @queue = :signup
  
  # Public: Store details of self-signups in CapsuleCRM
  #
  # membership   - a hash containing details of the new membership
  #              'product_name' => the membership level
  #              'number'       => the newly-generated membership number
  #              'join_date'    => the date of signup
  # 
  # organization - a hash containing details of the organization
  #              'name' => the org name in Xero - should be the same as that in capsule
  # 
  # Returns nil.
  def self.perform(organization, membership)
    organisation = CapsuleCRM::Organisation.find_all(:q => organization['name']).first
    if organisation.nil?
      Resque.enqueue_in(1.hour, SendSignupToCapsule, organization, membership)
    else
      # Create opportunity against organisation
      opportunity = CapsuleCRM::Opportunity.new(
        :party_id => organisation.id, 
        :name => "Membership at #{membership['product_name']} level",
        :currency => 'GBP',
        :description => "Membership #: #{membership['number']}",
        # :value => value_for_product_name(membership['product_name']),
        # :duration => 12,
        # :duration_basis => 'MONTH',
        :milestone => 'Won',
        :probability => 100,
        :expected_close_date => Date.parse(membership['join_date']),
        :owner => ENV['CAPSULECRM_DEFAULT_OWNER'],
      )
      opportunity.save
    end
  end
  
end