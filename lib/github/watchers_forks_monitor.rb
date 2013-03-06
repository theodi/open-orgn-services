class Github::WatchersForksMonitor
  
  @queue = :metrics
  
  def self.perform
    # Connect
    github = Github.connection
    # Count up stats across all repositories
    watchers = 0
    forks = 0
    github.repos.list(user: ENV['GITHUB_ORGANISATION']) do |repo|
      watchers += repo.watchers_count
      forks += repo.forks_count
    end
    # Push into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_WATCHERS'], watchers
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_FORKS'], forks
  end
  
end