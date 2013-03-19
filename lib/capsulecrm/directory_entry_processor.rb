class SendDirectoryEntryToCapsule
  @queue = :directoryentry
  
  extend CapsuleHelper

  # Public: Store directory entries for organisations in capsule
  #
  # organization      - a hash containing details of the organization
  #                   'name'         => the organisation name
  #
  # directory_entry   - a hash containing details of the directory entry
  #                   'description'  => the description that will appear against the
  #                                     organisation in the business directory
  #                   'homepage'     => the website address of the business
  #                   'logo'         => a url that links to the full size 
  #                                     version of the business's logo
  #                   'thumbnail'    => a url that links to the thumbnail 
  #                                     version of the business's logo
  #                   'date'         => the date and time of the update
  # 
  # date              - the date the data was added via the front-end as a string
  # 
  # Returns nil.

  def self.perform(organization, directory_entry, date)
    organisation = organization_by_name(organization['name'])
    if organisation.nil?
      requeue(organization, directory_entry, date)
    else
      if DateTime.parse(date) >= DateTime.parse(organisation.raw_data['updatedOn'])
        capsule = {}
        success = set_directory_entry_tag(
          organisation,
          'Description' => directory_entry['description'],
          'Homepage'    => directory_entry['homepage'],
          'Logo'        => directory_entry['logo'],
          'Thumbnail'   => directory_entry['thumbnail'],
        )
        unless success
          requeue(organization, directory_entry, date)
        end
      end
    end
  end
  
  def self.requeue(organization, directory_entry, date)
    Resque.enqueue_in(1.hour, SendDirectoryEntryToCapsule, organization, directory_entry, date)
  end
  
end