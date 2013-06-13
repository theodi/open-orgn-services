class EventSummaryUploader
  
  @queue = :invoicing
  
  # Public: Copies a JSON summary to a known file location (controlled by ENV variables)
  #
  # json - the JSON document to be uploaded
  #
  # Examples
  #
  #   EventSummaryUploader.perform("{'foo':'bar'}")
  #   # => nil
  #
  # Returns nothing
  def self.perform(json, type)
    require 'fog'
        
    service = Fog::Storage.new({
        :provider            => 'Rackspace',
        :rackspace_username  => ENV['RACKSPACE_USERNAME'],
        :rackspace_api_key   => ENV['RACKSPACE_API_KEY'],
        :rackspace_auth_url  => Fog::Rackspace::UK_AUTH_ENDPOINT,
        :rackspace_region    => :lon
    })

    # Upload to Rackspace
    # The container is in an ENV variable at the moment, as we can't currently mock requests away, so the files get put in a real place during tests. This is a bit crap, and needs sorting at some point.
    dir = service.directories.get ENV['RACKSPACE_CONTAINER']
    dir.files.create :key => "#{type}.json", :body => json
  end
  
end