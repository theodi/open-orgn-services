require 'httparty'
require 'json'

class Github::PullRequestMonitor
  
  @queue = :metrics
  
  extend MetricsHelper
  
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
    # Push into metrics
    store_metric "github-open-pull-requests", DateTime.now, open_pull_requests
    store_metric "github-total-pull-requests", DateTime.now, pull_requests
  rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
    # We sometimes get oauth timeouts on these requests. Let's just absorb them quietly and wait for the next time round.
    nil
  rescue Github::Error::InternalServerError, Github::Error::ServiceError
    # Sometimes Github gives us server errors too. Let's ignore those as well.
    nil
  end
  
end