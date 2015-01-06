class SendSignupToCapsule
  @queue = :signup

  extend ProductHelper
  extend CapsuleHelper

  # Public: Store details of self-signups in CapsuleCRM
  #
  # membership   - a hash containing details of the new membership
  #              'product_name'    => the membership level
  #              'supporter_level' => The supporter level
  #              'id'              => the newly-generated membership number
  #              'join_date'       => the date of signup
  #              'contact_email'   => a contact email for the signup
  #              'size'            => the organization's size
  #              'sector'          => the organization's sector
  #
  # party    - a hash containing details of the organization or person
  #              'name'           => the org / person name in Xero - should be the same as that in capsule
  #              'company_number' => the company number for the person or organization
  #              'email'          => the email address for the person or organization
  #
  # Returns nil.
  def self.perform(party, membership)
    if membership['product_name'] == "individual"
      p = find_person(party['email'])
    else
      p = find_organization(party['name'])
    end
    if p.nil?
      Resque.enqueue_in(1.hour, SendSignupToCapsule, party, membership)
    else
      # Create opportunity against organisation
      opportunity = CapsuleCRM::Opportunity.new(
        :party_id            => p.id,
        :name                => "Membership at #{membership['product_name']} level",
        :currency            => 'GBP',
        :description         => "Membership #: #{membership['id']}",
        :value               => product_value(membership['product_name']),
        :duration            => product_duration(membership['product_name']),
        :duration_basis      => product_basis(membership['product_name']),
        :milestone           => 'Invoiced',
        :probability         => 100,
        :expected_close_date => Date.parse(membership['join_date']),
        :owner               => ENV['CAPSULECRM_DEFAULT_OWNER'],
      )
      save_item(opportunity)
      # Write custom field for opportunity type
      field = CapsuleCRM::CustomField.new(
        opportunity,
        :label => 'Type',
        :text  => 'Membership'
      )
      save_item(field)
      # Set up membership tag
      set_membership_tag(
        p,
        "Level"           => membership['product_name'],
        "Supporter Level" => membership['supporter_level'],
        "ID"              => membership['id'],
        "Joined"          => Date.parse(membership['join_date']),
        "Email"           => membership['contact_email'],
        "Size"            => membership['size'],
        "Sector"          => membership['sector']
      )
      unless membership['product_name'] == "individual"
        # Store company number on organization
        field = CapsuleCRM::CustomField.new(
          p,
          :label => 'Company Number',
          :text  => party['company_number'],
        )
        save_item(field)
      end
    end
  end

end
