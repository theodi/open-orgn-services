def github
  $github ||= Github.new login: ENV['GITHUB_USER'], password: ENV['GITHUB_PASSWORD'], user: ENV['GITHUB_ORGANISATION']
end
  

Given /^there are (\d+) public repositories on github$/ do |num_repos|
  VCR.use_cassette('github_check_public_repos') do
    @org = github.orgs.find(ENV['GITHUB_ORGANISATION'])
    @org.public_repos.should == num_repos.to_i
  end
end

Given /^the repository "(.*?)" has (\d+) open issues?$/ do |repo, open_issues|
  VCR.use_cassette("github_check_open_issues_on_#{repo}") do
    @repo = github.repos.find(ENV['GITHUB_ORGANISATION'], repo)
    @repo.open_issues_count.should == open_issues.to_i
  end
end

Given /^the repository "(.*?)" has (\d+) watchers?$/ do |repo, watchers|
  VCR.use_cassette("github_check_watchers_on_#{repo}") do
    @repo = github.repos.find(ENV['GITHUB_ORGANISATION'], repo)
    @repo.watchers_count.should == watchers.to_i
  end
end

Given /^the repository "(.*?)" has (\d+) forks?$/ do |repo, forks|
  VCR.use_cassette("github_check_forks_on_#{repo}") do
    @repo = github.repos.find(ENV['GITHUB_ORGANISATION'], repo)
    @repo.forks_count.should == forks.to_i
  end
end

Given /^the repository "(.*?)" has (\d+) open pull requests?$/ do |repo, open_prs|
  VCR.use_cassette("github_check_open_pull_requests_on_#{repo}") do
    @pulls = github.pulls.list(ENV['GITHUB_ORGANISATION'], repo)
    @pulls.count.should == open_prs.to_i
  end
end

Given /^the repository "(.*?)" has (\d+) closed pull requests?$/ do |repo, closed_prs|
  VCR.use_cassette("github_check_closed_pull_requests_on_#{repo}") do
    @pulls = github.pulls.list(ENV['GITHUB_ORGANISATION'], repo, state: 'closed')
    @pulls.count.should == closed_prs.to_i
  end
end

When /^the github monitor runs$/ do
  VCR.use_cassette('github_monitor') do
    GithubMonitor.perform
  end
end

def statistic_id(stat_name)
  ids = {
    'public repositories' => 'LEFTRONIC_GITHUB_REPOS',
    'open issues' => 'LEFTRONIC_GITHUB_ISSUES',
    'watchers' => 'LEFTRONIC_GITHUB_WATCHERS',
    'forks' => 'LEFTRONIC_GITHUB_FORKS',
    'open pull requests' => 'LEFTRONIC_GITHUB_OPENPRS',
    'total pull requests' => 'LEFTRONIC_GITHUB_PULLS',
  }
  if ids[stat_name]
    ENV[ids[stat_name]]
  else
    raise ArgumentError.new("Unknown stat #{stat_name}")
  end
end