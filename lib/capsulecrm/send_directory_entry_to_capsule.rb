class SendDirectoryEntryToCapsule
  @queue = :directoryentry
  
  extend CapsuleHelper

  # Public: Store directory entries for organisations in capsule
  #
  # membership_id     - the membership ID to match on
  #
  # organization      - a hash containing details of the organization
  #                   'name'         => the organisation name
  #
  # directory_entry   - a hash containing details of the directory entry
  #                   'active'       => whether the organization should be active or not
  #                   'description'  => the description that will appear against the
  #                                     organisation in the business directory
  #                   'homepage'     => the website address of the business
  #                   'logo'         => a url that links to the full size 
  #                                     version of the business's logo
  #                   'thumbnail'    => a url that links to the thumbnail 
  #                                     version of the business's logo
  #                   'date'         => the date and time of the update
  #                   'contact'      => the name of the contact person to show in the directory
  #                   'phone'        => the phone number for the directory
  #                   'email'        => the email address for the directory
  #                   'twitter'      => organization twitter account
  #                   'linkedin'     => organization linkedin url
  #                   'facebook'     => organization facebook url 
  #                   'tagline'      => organization tag line
  # 
  # date              - the date the data was added via the front-end as a string
  # 
  # Returns nil.

  def self.perform(membership_id, organization, directory_entry, date)
    org = find_organization(membership_id)
    if org.nil?
      requeue(membership_id, organization, directory_entry, date)
    else
      # Chunk description into 250-char sections
      description = directory_entry['description'].to_s.scan(/.{1,250}/)
      # Store
      fields = {
        'Active'        => directory_entry['active'],
        'Description'   => description[0],
        'Description-2' => description[1],
        'Description-3' => description[2],
        'Description-4' => description[3],
        'Homepage'      => directory_entry['homepage'],
        'Logo'          => directory_entry['logo'],
        'Thumbnail'     => directory_entry['thumbnail'],
        'Contact'       => directory_entry['contact'],
        'Phone'         => directory_entry['phone'],
        'Email'         => directory_entry['email'],
        'Twitter'       => directory_entry['twitter'],
        'LinkedIn'      => directory_entry['linkedin'],
        'Facebook'      => directory_entry['facebook'],          
        'Tagline'       => directory_entry['tagline'], 
      }.compact
      success = set_directory_entry_tag(org, fields)
      unless success
        requeue(membership_id, organization, directory_entry, date)
      end
    end
  end
  
  def self.requeue(membership_id, organization, directory_entry, date)
    Resque.enqueue_in(1.hour, SendDirectoryEntryToCapsule, membership_id, organization, directory_entry, date)
  end
  
end