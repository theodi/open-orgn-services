require "observer"

class SyncCapsuleData
  @queue = :directory # This runs inside the directory app
  
  extend Observable
  extend CapsuleHelper
  
  # Syncs a single organization into the local DB
  def self.perform(organization_id)
    # Get the organization from capsule
    org = CapsuleCRM::Organisation.find(organization_id)
    if org
      data = {
        'membership' => {
          'email'         => field(org, "Membership", "Email").try(:text),
          'product_name'  => field(org, "Membership", "Level").try(:text),
          'membership_id' => field(org, "Membership", "ID").try(:text),
        }.compact,
        'directory_entry' => {
          'active'        => field(org, "DirectoryEntry", "Active").try(:boolean).try(:to_s),
          'name'          => org.name,
          'description'   => field(org, "DirectoryEntry", "Description").try(:text),
          'url'           => field(org, "DirectoryEntry", "Homepage").try(:text),
          'contact'       => field(org, "DirectoryEntry", "Contact").try(:text),
          'phone'         => field(org, "DirectoryEntry", "Phone").try(:text),
          'email'         => field(org, "DirectoryEntry", "Email").try(:text),
          'twitter'       => field(org, "DirectoryEntry", "Twitter").try(:text),
          'linkedin'      => field(org, "DirectoryEntry", "Linkedin").try(:text),
          'facebook'      => field(org, "DirectoryEntry", "Facebook").try(:text),          
        }.compact,
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

