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
        'product_name'=> field(org, "Membership", "Level").text,
        'email'       => field(org, "Membership", "Email").text,
        'name'        => org.name,
        'active'      => field(org, "DirectoryEntry", "Active").boolean.to_s,
        'description' => field(org, "DirectoryEntry", "Description").text,
        'url'         => field(org, "DirectoryEntry", "Homepage").text,
      }
      # Notify the observers
      changed
      notify_observers(data)
    end
  end
  
  def self.field(org, tag, field)
    org.custom_fields.find{|x| x.label == field && x.tag == tag}
  end
  
end

