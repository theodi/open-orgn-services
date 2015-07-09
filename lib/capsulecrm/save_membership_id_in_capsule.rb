class SaveMembershipIdInCapsule
  @queue = :signup
  
  extend CapsuleHelper

  # Public: Store details of self-signups in CapsuleCRM
  #
  # organization_name - If not nil, The name of the organization to store against
  # individual_email  - If not nil, the email of the individual member to store against
  # membership_id     - The membership ID to store
  # 
  # Returns nil.
  def self.perform(organization_name, individual_email, membership_id)
    # Find organization
    if organization_name
      party = find_organization(organization_name)
      raise ArgumentError.new("Organization name #{organization_name} not found") if party.nil?
    elsif individual_email
      party = find_person(individual_email)
      raise ArgumentError.new("Person #{individual_email} not found") if party.nil?
    else
      raise ArgumentError.new("No party details supplied for member #{membership_id}")
    end
    # Store membership ID
    set_membership_tag(party, "ID" => membership_id)
  end
    
end