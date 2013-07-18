class Github::OrganisationMonitor
  
  @queue = :metrics
  
  def self.perform
    # Get github organisation
    org = Github.connection.orgs.find(ENV['GITHUB_ORGANISATION'])
    # Public repository count into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_REPOS'], org.public_repos
  rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
    # We sometimes get oauth timeouts on these requests. Let's just absorb them quietly and wait for the next time round.
    nil
  rescue Github::Error::InternalServerError, Github::Error::ServiceError
    # Sometimes Github gives us server errors too. Let's ignore those as well.
    nil
  end
  
end