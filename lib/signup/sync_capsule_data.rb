require "observer"

class SyncCapsuleData
  @queue = :directory # This runs inside the directory app
  
  extend Observable
  
  # Syncs a single organization into the local DB
  def self.perform(organization_id)
    # Get the organization from capsule
    org = CapsuleCRM::Organisation.find(organization_id)
    if org
      data = {
        'product_name'  => field(org, "Membership", "Level").try(:text),
        'email'         => field(org, "Membership", "Email").try(:text),
        'membership_id' => field(org, "Membership", "ID").try(:text),
        'name'          => org.name,
        'active'        => field(org, "DirectoryEntry", "Active").try(:boolean).try(:to_s),
        'description'   => field(org, "DirectoryEntry", "Description").try(:text),
        'url'           => field(org, "DirectoryEntry", "Homepage").try(:text),
      }.compact
      # Notify the observers
      changed
      notify_observers(data)
    end
  end
  
  def self.field(org, tag, field)
    org.custom_fields.find{|x| x.label == field && x.tag == tag}
  end
  
end

