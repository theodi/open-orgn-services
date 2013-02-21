def github
  $github ||= Github.new login: ENV['GITHUB_USER'], password: ENV['GITHUB_PASSWORD'], user: ENV['GITHUB_ORGANISATION']
end
  

Given /^there are (\d+) public repositories on github$/ do |num_repos|
  @org = github.orgs.find(ENV['GITHUB_ORGANISATION'])
  @org.public_repos.should == num_repos.to_i
end

Given /^the repository "(.*?)" has (\d+) open issues?$/ do |repo, open_issues|
  @repo = github.repos.find(ENV['GITHUB_ORGANISATION'], repo)
  @repo.open_issues_count.should == open_issues.to_i
end

Given /^the repository "(.*?)" has (\d+) watchers?$/ do |repo, watchers|
  @repo = github.repos.find(ENV['GITHUB_ORGANISATION'], repo)
  @repo.watchers_count.should == watchers.to_i
end

Given /^the repository "(.*?)" has (\d+) forks?$/ do |repo, forks|
  @repo = github.repos.find(ENV['GITHUB_ORGANISATION'], repo)
  @repo.forks_count.should == forks.to_i
end

Given /^the repository "(.*?)" has (\d+) open pull requests?$/ do |repo, open_prs|
  @pulls = github.pulls.list(ENV['GITHUB_ORGANISATION'], repo)
  @pulls.count.should == open_prs.to_i
end

Given /^the repository "(.*?)\/(.*?)" has (#{INTEGER}) pull requests? from us?$/ do |user, repo, open_prs|
  @pulls = github.pulls.list(user, repo).select{|x| x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION']}
  @pulls.count.should == open_prs.to_i
end

Given /^the repository "(.*?)" has (\d+) closed pull requests?$/ do |repo, closed_prs|
  @pulls = github.pulls.list(ENV['GITHUB_ORGANISATION'], repo, state: 'closed')
  @pulls.count.should == closed_prs.to_i
end

When /^the github monitor runs$/ do
  GithubMonitor.perform
end