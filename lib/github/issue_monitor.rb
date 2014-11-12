class Github::IssueMonitor
  
  @queue = :metrics
  
  extend MetricsHelper
  
  def self.perform
    # Connect
    github = Github.connection
    # Count up stats across all repositories
    open_issues = 0
    github.repos.list(user: ENV['GITHUB_ORGANISATION']) do |repo|
      open_issues += repo.open_issues_count
    end
    # Push into metrics
    store_metric "github-open-issue-count", DateTime.now, open_issues
  rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
    # We sometimes get oauth timeouts on these requests. Let's just absorb them quietly and wait for the next time round.
    nil
  rescue Github::Error::InternalServerError, Github::Error::ServiceError
    # Sometimes Github gives us server errors too. Let's ignore those as well.
    nil
  end
  
end