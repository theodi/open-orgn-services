class Github::OrganisationMonitor
  
  @queue = :metrics
  
  def self.perform
    # Get github organisation
    org = Github.connection.orgs.find(ENV['GITHUB_ORGANISATION'])
    # Public repository count into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_REPOS'], org.public_repos
  end
  
end