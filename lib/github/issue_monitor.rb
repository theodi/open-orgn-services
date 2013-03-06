class Github::IssueMonitor
  
  @queue = :metrics
  
  def self.perform
    # Connect
    github = Github.connection
    # Count up stats across all repositories
    open_issues = 0
    github.repos.list(user: ENV['GITHUB_ORGANISATION']) do |repo|
      open_issues += repo.open_issues_count
    end
    # Push into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_ISSUES'], open_issues
  end
  
end