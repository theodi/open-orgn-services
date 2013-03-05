Given /^there are (\d+) public repositories on github$/ do |num_repos|
  @org = Github.connection.orgs.find(ENV['GITHUB_ORGANISATION'])
  @org.public_repos.should == num_repos.to_i
end

Given /^the repository "(.*?)" has (\d+) open issues?$/ do |repo, open_issues|
  @repo = Github.connection.repos.find(ENV['GITHUB_ORGANISATION'], repo)
  @repo.open_issues_count.should == open_issues.to_i
end

Given /^the repository "(.*?)" has (\d+) watchers?$/ do |repo, watchers|
  @repo = Github.connection.repos.find(ENV['GITHUB_ORGANISATION'], repo)
  @repo.watchers_count.should == watchers.to_i
end

Given /^the repository "(.*?)" has (\d+) forks?$/ do |repo, forks|
  @repo = Github.connection.repos.find(ENV['GITHUB_ORGANISATION'], repo)
  @repo.forks_count.should == forks.to_i
end

Given /^the repository "(.*?)" has (\d+) open pull requests?$/ do |repo, open_prs|
  @pulls = Github.connection.pulls.list(ENV['GITHUB_ORGANISATION'], repo)
  @pulls.count.should == open_prs.to_i
end

Given /^the repository "(.*?)\/(.*?)" has (#{INTEGER}) pull requests? from us?$/ do |user, repo, open_prs|
  @pulls = Github.connection.pulls.list(user, repo).select{|x| x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION']}
  count = @pulls.count
  @pulls = Github.connection.pulls.list(user, repo, state: 'closed').select{|x| x[:head][:repo] && x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION']}
  count += @pulls.count
  count.should == open_prs.to_i
end

Given /^the repository "(.*?)" has (\d+) closed pull requests?$/ do |repo, closed_prs|
  @pulls = Github.connection.pulls.list(ENV['GITHUB_ORGANISATION'], repo, state: 'closed')
  @pulls.count.should == closed_prs.to_i
end

When /^the github organisation monitor runs$/ do
  Github::OrganisationMonitor.perform
end

When /^the github issue monitor runs$/ do
  Github::IssueMonitor.perform
end

When /^the github watcher and fork monitor runs$/ do
  Github::WatchersForksMonitor.perform
end

When /^the github pull request monitor runs$/ do
  Github::PullRequestMonitor.perform
end

When /^the github outgoing pull request monitor runs$/ do
  Github::OutgoingPullRequestMonitor.perform
end