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
      begin
        issues = github.issues.list(user: ENV['GITHUB_ORGANISATION'], repo: repo.name)
      rescue Github::Error::ServiceError # gets raised if issues are disabled
        issues = []
      end
      open_pull_requests += issues.select{|x| x["state"] == "open" && x["pull_request"] && x["pull_request"]["html_url"]}.count
      # Tot up open and closed pull requests for the total count
      pull_requests += issues.select{|x| x["pull_request"] && x["pull_request"]["html_url"]}.count
    end
    # Push into leftronic
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_ISSUES'], open_issues
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_WATCHERS'], watchers
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_FORKS'], forks
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_OPENPRS'], open_pull_requests
    Resque.enqueue LeftronicPublisher, :number, ENV['LEFTRONIC_GITHUB_PULLS'], pull_requests
  end
  
end