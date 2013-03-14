class SendDirectoryEntryToCapsule
  @queue = :directoryentry
  
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
  # date              - the date the data was added via the front-end
  #                     as a DateTime object
  # 
  # Returns nil.

  def self.perform(organization, directory_entry, date)
    organisation = CapsuleCRM::Organisation.find_all(:q => organization['name']).first
    if organisation.nil?
      Resque.enqueue_in(1.hour, SendDirectoryEntryToCapsule, organization, directory_entry, date)
    else
      if DateTime.parse(date) >= DateTime.parse(organisation.raw_data['updatedOn'])
        capsule = {}
        # Create new data tag for directory entry
        capsule[:tag] = CapsuleCRM::Tag.new(
          organisation,
          :name => 'DirectoryEntry'
        )
        # Set custom fields (in data tag)
        capsule[:description] = CapsuleCRM::CustomField.new(
          organisation,
          :tag => 'DirectoryEntry',
          :label => 'Description',
          :text => directory_entry['description'],
        )
        capsule[:url] = CapsuleCRM::CustomField.new(
          organisation,
          :tag => 'DirectoryEntry',
          :label => 'Homepage',
          :text => directory_entry['homepage'],
        )
        capsule[:logo] = CapsuleCRM::CustomField.new(
          organisation,
          :tag => 'DirectoryEntry',
          :label => 'Logo',
          :text => directory_entry['logo'],
        )
        capsule[:thumb] = CapsuleCRM::CustomField.new(
          organisation,
          :tag => 'DirectoryEntry',
          :label => 'Thumbnail',
          :text => directory_entry['thumbnail'],
        )
        capsule.each do |obj, val|
          val.save
          unless CapsuleCRM::Base.last_response.code <= 201
            Resque.enqueue_in(1.hour, SendDirectoryEntryToCapsule, organization, directory_entry)
          end
        end
      end
    end
  end
  
end