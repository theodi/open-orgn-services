require "observer"

class SyncCapsuleData
  @queue = :directory # This runs inside the directory app

  extend Observable
  extend CapsuleHelper

  # Syncs a single person or organisarion into the local DB
  def self.perform(id, type)
    # Get the subject from capsule
    subject = "CapsuleCRM::#{type.titleize}".constantize.find(id)
    if subject
      membership = {
        'email'                    => field(subject, "Membership", "Email").try(:text),
        'product_name'             => product_name(subject),
        'id'                       => field(subject, "Membership", "ID").try(:text),
        'newsletter'               => field(subject, "Membership", "Newsletter").try(:boolean),
        'share_with_third_parties' => field(subject, "Membership", "Share with third parties").try(:boolean),
        'size'                     => field(subject, "Membership", "Size").try(:text),
        'sector'                   => field(subject, "Membership", "Sector").try(:text),
        'contact_first_name'       => field(subject, "Membership", "Contact first name").try(:text),
        'contact_last_name'        => field(subject, "Membership", "Contact last name").try(:text),
      }.compact
      description = [
        field(subject, "DirectoryEntry", "Description").try(:text),
        field(subject, "DirectoryEntry", "Description-2").try(:text),
        field(subject, "DirectoryEntry", "Description-3").try(:text),
        field(subject, "DirectoryEntry", "Description-4").try(:text)
      ].compact.join
      directory_entry = {
        'active'        => field(subject, "DirectoryEntry", "Active").try(:boolean).try(:to_s),
        'name'          => subject.respond_to?(:name) ? subject.name : nil,
        'description'   => description.present? ? description : nil,
        'url'           => field(subject, "DirectoryEntry", "Homepage").try(:text),
        'contact'       => field(subject, "DirectoryEntry", "Contact").try(:text),
        'phone'         => field(subject, "DirectoryEntry", "Phone").try(:text),
        'email'         => field(subject, "DirectoryEntry", "Email").try(:text),
        'twitter'       => field(subject, "DirectoryEntry", "Twitter").try(:text),
        'linkedin'      => field(subject, "DirectoryEntry", "Linkedin").try(:text),
        'facebook'      => field(subject, "DirectoryEntry", "Facebook").try(:text),
        'tagline'       => field(subject, "DirectoryEntry", "Tagline").try(:text),
      }.compact
      # Notify the observers
      changed
      notify_observers(membership, directory_entry, id)
    end
  end

  def self.product_name(subject)
    level           = field(subject, "Membership", "Level").try(:text)
    supporter_level = field(subject, "Membership", "Supporter Level").try(:text)

    if level == "individual" && supporter_level == "Student"
      "student"
    else
      level
    end
  end
end
