class SaveMembershipIdInCapsule
  @queue = :signup
  
  extend CapsuleHelper

  # Public: Store details of self-signups in CapsuleCRM
  #
  # organization_name - The name of the organization to store against
  # membership_id     - The membership ID to store
  # 
  # Returns nil.
  def self.perform(organization_name, membership_id)
    # Find organization
    organization = organization_by_name(organization_name)
    raise ArgumentError.new("Organization name #{organization_name} not found") if organization.nil?
    # Store membership ID
    set_membership_tag(organization, "ID" => membership_id)
  end
    
end