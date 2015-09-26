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
    party = find_org_by_membership_id(membership_id) || find_person_by_membership_id(membership_id)
    if party.nil?
      requeue(membership_id, membership)
    else
      success = set_membership_tag(
        party,
        'Email'                    => membership['email'],
        'Newsletter'               => membership['newsletter'],
        'Share with third parties' => membership['share_with_third_parties'],
        'Size'                     => membership['size'],
        'Sector'                   => membership['sector']
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