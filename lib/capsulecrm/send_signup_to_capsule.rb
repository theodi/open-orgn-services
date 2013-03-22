class SendSignupToCapsule
  @queue = :signup
  
  extend ProductHelper
  extend CapsuleHelper

  # Public: Store details of self-signups in CapsuleCRM
  #
  # membership   - a hash containing details of the new membership
  #              'product_name' => the membership level
  #              'id'           => the newly-generated membership number
  #              'join_date'    => the date of signup
  #              'contact_email'=> a contact email for the signup
  # 
  # organization - a hash containing details of the organization
  #              'name' => the org name in Xero - should be the same as that in capsule
  # 
  # Returns nil.
  def self.perform(organization, membership)
    org = find_organization(organization['name'])
    if org.nil?
      Resque.enqueue_in(1.hour, SendSignupToCapsule, organization, membership)
    else
      # Create opportunity against organisation
      opportunity = CapsuleCRM::Opportunity.new(
        :party_id            => org.id, 
        :name                => "Membership at #{membership['product_name']} level",
        :currency            => 'GBP',
        :description         => "Membership #: #{membership['id']}",
        :value               => product_value(membership['product_name']),
        :duration            => product_duration(membership['product_name']),
        :duration_basis      => product_basis(membership['product_name']),
        :milestone           => 'Won',
        :probability         => 100,
        :expected_close_date => Date.parse(membership['join_date']),
        :owner               => ENV['CAPSULECRM_DEFAULT_OWNER'],
      )
      opportunity.save
      # Write custom field for opportunity type
      field = CapsuleCRM::CustomField.new(
        opportunity,
        :label => 'Type',
        :text  => 'Membership'
      )
      field.save
      # Set up membership tag
      set_membership_tag(
        org,
        "Level"  => membership['product_name'],
        "ID"     => membership['id'],
        "Joined" => Date.parse(membership['join_date']),
        "Email"  => membership['contact_email']
      )
    end
  end

end