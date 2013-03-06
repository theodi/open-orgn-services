require 'pry'

class SendSignupToCapsule
  @queue = :signup
  
  # Public: Store details of self-signups in CapsuleCRM
  #
  #
  # Returns nil.
  def self.perform(organization, membership)
    organisation = CapsuleCRM::Organisation.find_all(:q => organization['name']).first
    if organisation.nil?
      Resque.enqueue_in(1.hour, SendSignupToCapsule, organization, membership)
    end
  end
  
end