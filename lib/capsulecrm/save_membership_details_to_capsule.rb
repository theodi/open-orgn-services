class SaveMembershipDetailsToCapsule
  @queue = :signup
  
  extend CapsuleHelper

  # Public: Store updated membership details for organisations in capsule
  #
  # membership_id     - the membership ID to match on
  #
  # membership        - a hash containing details for the membership
  #                   'email'        => the contact email address
  #                   'newsletter'   => whether to send a newsletter or not
  #                   'size'         => the organization size
  #                   'sector'       => the organization's industry sector
  # 
  # Returns nil.

  def self.perform(membership_id, membership)
    org = find_organization(membership_id)
    if org.nil?
      requeue(membership_id, membership)
    else
      success = set_membership_tag(
        org,
        'Email'      => membership['email'],
        'Newsletter' => membership['newsletter'],
        'Size'       => membership['size'],
        'Sector'     => membership['sector']
      )
      unless success
        requeue(membership_id, membership)
      end
    end
  end
  
  def self.requeue(membership_id, membership)
    Resque.enqueue_in(1.hour, SaveMembershipDetailsToCapsule, membership_id, membership)
  end
  
end