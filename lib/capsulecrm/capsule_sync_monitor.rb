class CapsuleSyncMonitor
  @queue = :signup

  extend CapsuleHelper

  # This monitors capsuleCRM for changes and queues up individual changes for update in the frontend app
  def self.perform
    [
      :orgs,
      :people
    ].each do |type|
      self.send(type).each { |t| enqueue_sync(t, t.class.name.demodulize) }
    end
  end

  def self.enqueue_sync(org, type)
    if org.updated_at > 2.hours.ago
      Resque.enqueue(SyncCapsuleData, org.id, type)
    end
  end

  def self.orgs
    CapsuleCRM::Organisation.find_all(:tag => "Membership")
  end

  def self.people
    CapsuleCRM::Person.find_all(:tag => "Membership")
  end

end
