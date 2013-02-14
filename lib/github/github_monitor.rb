require 'github_api'

class GithubMonitor
  
  @queue = :metrics
  
  def self.perform
    # Connect
    github = Github.new login: ENV['GITHUB_USER'], password: ENV['GITHUB_PASSWORD'], user: ENV['GITHUB_ORGANISATION']
    # Get github organisation
    org = github.orgs.find(ENV['GITHUB_ORGANISATION'])
    # Public repos into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_REPOS'], org.public_repos
    # Count up stats across all repositories
    open_issues = 0
    watchers = 0
    forks = 0
    open_pull_requests = 0
    pull_requests = 0
    github.repos.list(user: ENV['GITHUB_ORGANISATION']) do |repo|
      open_issues += repo.open_issues_count
      watchers += repo.watchers_count
      forks += repo.forks_count
      open_pulls = github.pulls.list(ENV['GITHUB_ORGANISATION'], repo.name)
      open_pull_requests += open_pulls.count
      pull_requests += open_pulls.count
      pull_requests += github.pulls.list(ENV['GITHUB_ORGANISATION'], repo.name, state: 'closed').count
    end
    # Push into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_ISSUES'], open_issues
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_WATCHERS'], watchers
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_FORKS'], forks
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_OPENPRS'], open_pull_requests
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_PULLS'], pull_requests
  end
  
end