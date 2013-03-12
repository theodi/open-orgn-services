class SendDirectoryEntryToCapsule
  @queue = :directoryentry
  
  # Public: Store directory entries for organisations in capsule
  #
  # organization      - a hash containing details of the organization
  #                   'name'         => the organisation name
  #
  # directory_entry   - a hash containing details of the directory entry
  #                  'description'  => the description that will appear against the
  #                                organisation in the business directory
  #                  'url'          => the website address of the business
  #                  'logo'         => a url that links to the full size 
  #                                version of the business's logo
  # 
  # 
  # Returns nil.

  def self.perform(organization, directory_entry)
    organisation = CapsuleCRM::Organisation.find_all(:q => organization['name']).first
    if organisation.nil?
      Resque.enqueue_in(1.hour, SendDirectoryEntryToCapsule, organization, directory_entry)
    else
      # Create new data tag for directory entry
      tag = CapsuleCRM::Tag.new(
        organisation,
        :name => URI::encode('Directory entry')
      )
      tag.save
      # Set custom fields (in data tag)
      field = CapsuleCRM::CustomField.new(
        organisation,
        :tag => 'Directory entry',
        :label => 'Description',
        :text => directory_entry['description'],
      )
      field.save
      field = CapsuleCRM::CustomField.new(
        organisation,
        :tag => 'Directory entry',
        :label => 'Url',
        :text => directory_entry['url'],
      )
      field.save
      field = CapsuleCRM::CustomField.new(
        organisation,
        :tag => 'Directory entry',
        :label => 'Logo',
        :text => directory_entry['logo'],
      )
      field.save
    end
  end
  
end