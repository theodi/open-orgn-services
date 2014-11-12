@vcr 
Feature: Github monitoring

  In order to track our open-source metrics
  As a member of the tech team
  I want to capture stats from github and push them to a dashboard
  
  Scenario: get public repository count
    Given there are 27 public repositories on github
    Then the following data should be stored in the "github-repository-count" metric
      """
      27
      """
    When the github organisation monitor runs

  Scenario: get open issue count  
    Given the repository "capsulecrm" has 1 open issue
    And   the repository "csv-profiler" has 1 open issue
    And   the repository "hot-drinks" has 1 open issue
    And   the repository "member-directory" has 11 open issues
    And   the repository "open-data-certificate" has 20 open issues
    And   the repository "open-data-tech-review" has 1 open issue
    And   the repository "open-orgn-services" has 75 open issues
    And   the repository "public-displays" has 2 open issues
    And   the repository "services-manager" has 1 open issue
    And   the repository "signin-web" has 7 open issues
    Then the following data should be stored in the "github-open-issue-count" metric
      """
      120
      """
    When the github issue monitor runs

  Scenario: get watcher count
    Given the repository "bootstrap" has 1 watcher
    And the repository "open-data-certificate" has 1 watcher
    And the repository "open-data-tech-review" has 29 watchers
    Then the following data should be stored in the "github-watchers" metric
      """
      31
      """
    When the github watcher and fork monitor runs

  Scenario: get fork count
    Given the repository "hot-drinks" has 1 fork
    And the repository "odibot" has 1 fork
    And the repository "open-data-tech-review" has 4 forks
    Then the following data should be stored in the "github-forks" metric
      """
      6
      """
    When the github watcher and fork monitor runs

  Scenario: get open pull request count
    Given the repository "capsulecrm" has 1 open pull request
    And the repository "member-directory" has 2 open pull requests
    And the repository "open-orgn-services" has 1 open pull request
    And the repository "services-manager" has 1 open pull request
    Then the following data should be stored in the "github-open-pull-requests" metric
      """
      5
      """
    When the github pull request monitor runs

  Scenario: get total pull request count
    Given the repository "capsulecrm" has 1 open pull request
    And the repository "bootstrap" has 2 closed pull requests
    And the repository "hot-drinks" has 2 closed pull requests
    And the repository "member-directory" has 2 open pull requests
    And the repository "member-directory" has 23 closed pull requests
    And the repository "odibot" has 1 closed pull requests
    And the repository "open-orgn-services" has 1 open pull request
    And the repository "open-orgn-services" has 30 closed pull requests
    And the repository "public-keys" has 3 closed pull requests
    And the repository "services-manager" has 1 open pull request
    And the repository "services-manager" has 3 closed pull requests
    And the repository "signin-web" has 5 closed pull requests
    And the repository "www" has 10 closed pull requests
    Then the following data should be stored in the "github-total-pull-requests" metric
      """
      84
      """
    When the github pull request monitor runs
    
  Scenario: get outgoing pull request count
    Given the repository "Atalanta/cucumber-chef" has 1 pull request from us
    And the repository "nandub/hubot-irc" has 1 pull request from us
    And the repository "cassianoleal/vagrant-butcher" has 1 pull request from us
    And the repository "waynerobinson/xeroizer" has 1 pull request from us
    Then the following data should be stored in the "github-outgoing-pull-requests" metric
      """
      4
      """
    When the github outgoing pull request monitor runs
