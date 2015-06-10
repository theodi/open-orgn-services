class CapsuleSyncMonitor
  @queue = :signup

  extend CapsuleHelper

  # This monitors capsuleCRM for changes and queues up individual changes for update in the frontend app
  def self.perform
    orgs.each { |org| enqueue_sync(org) }
    people.each { |person| enqueue_sync(person) }
  end

  def self.enqueue_sync(org)
    if org.updated_at > 2.hours.ago
      Resque.enqueue(SyncCapsuleData, org.id)
    end
  end

  def self.orgs
    CapsuleCRM::Organisation.find_all(:tag => "Membership")
  end

  def self.people
    CapsuleCRM::Person.find_all(:tag => "Membership")
  end

end
