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
      membership = {
        'email'         => field(org, "Membership", "Email").try(:text),
        'product_name'  => field(org, "Membership", "Level").try(:text),
        'id'            => field(org, "Membership", "ID").try(:text),
        'newsletter'    => field(org, "Membership", "Newsletter").try(:boolean),
      }.compact
      description = [
        field(org, "DirectoryEntry", "Description").try(:text),
        field(org, "DirectoryEntry", "Description-2").try(:text),
        field(org, "DirectoryEntry", "Description-3").try(:text),
        field(org, "DirectoryEntry", "Description-4").try(:text)
      ].compact.join
      directory_entry = {
        'active'        => field(org, "DirectoryEntry", "Active").try(:boolean).try(:to_s),
        'name'          => org.name,
        'description'   => description.present? ? description : nil,
        'url'           => field(org, "DirectoryEntry", "Homepage").try(:text),
        'contact'       => field(org, "DirectoryEntry", "Contact").try(:text),
        'phone'         => field(org, "DirectoryEntry", "Phone").try(:text),
        'email'         => field(org, "DirectoryEntry", "Email").try(:text),
        'twitter'       => field(org, "DirectoryEntry", "Twitter").try(:text),
        'linkedin'      => field(org, "DirectoryEntry", "Linkedin").try(:text),
        'facebook'      => field(org, "DirectoryEntry", "Facebook").try(:text),          
        'tagline'       => field(org, "DirectoryEntry", "Tagline").try(:text),          
      }.compact
      # Notify the observers
      changed
      notify_observers(membership, directory_entry)
    end
  end
  
  def self.field(org, tag, field)
    org.custom_fields.find{|x| x.label == field && x.tag == tag}
  end
  
end

