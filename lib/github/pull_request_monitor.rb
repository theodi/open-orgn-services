class Github::PullRequestMonitor
  
  @queue = :metrics
  
  def self.perform
    # Connect
    github = Github.connection
    # Count up stats across all repositories
    open_pull_requests = 0
    pull_requests = 0
    github.repos.list(user: ENV['GITHUB_ORGANISATION']) do |repo|
      open_pulls = github.pulls.list(ENV['GITHUB_ORGANISATION'], repo.name)
      open_pull_requests += open_pulls.count
      pull_requests += open_pulls.count
      closed_pulls = github.pulls.list(ENV['GITHUB_ORGANISATION'], repo.name, state: 'closed')
      pull_requests += closed_pulls.count
    end
    # Push into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_OPENPRS'], open_pull_requests
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_PULLS'], pull_requests
  end
  
end