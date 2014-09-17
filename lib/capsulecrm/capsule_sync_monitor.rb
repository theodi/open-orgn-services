class CapsuleSyncMonitor
  @queue = :signup
  
  extend CapsuleHelper
  
  # This monitors capsuleCRM for changes and queues up individual changes for update in the frontend app
  def self.perform
    orgs = CapsuleCRM::Organisation.find_all(:tag => "Membership")
    orgs.each do |org|
      # Check if data tags have been updated
      # Updated at time should be more recent than 2 hours ago
      if org.updated_at > 2.hours.ago
        Resque.enqueue(SyncCapsuleData, org.id)
      end
    end
  end
  
end