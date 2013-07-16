class Github::OutgoingPullRequestMonitor
  
  @queue = :metrics
  
  def self.perform
    # Connect
    github = Github.connection
    # Count up stats across all repositories
    outgoing_pull_requests = 0
    github.repos.list(user: ENV['GITHUB_ORGANISATION']) do |repo|
      if repo.fork
        r = github.repos.find(ENV['GITHUB_ORGANISATION'], repo.name)
        # Open PRs
        parent_pulls = github.pulls.list(r[:parent][:owner][:login], r[:parent][:name])
        count = parent_pulls.select{|x| x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION']}.count rescue 0
        # Closed PRs
        parent_pulls = github.pulls.list(r[:parent][:owner][:login], r[:parent][:name], state: 'closed')
        count += parent_pulls.select{|x| x[:head][:repo] && x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION']}.count
        # Store
        outgoing_pull_requests += count
      end
    end
    # Push into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_OUTGOING_PRS'], outgoing_pull_requests
  rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
    # We sometimes get oauth timeouts on these requests. Let's just absorb them quietly and wait for the next time round.
    nil
  rescue Github::Error::InternalServerError, Github::Error::ServiceError
    # Sometimes Github gives us server errors too. Let's ignore those as well.
    nil
  end
  
end