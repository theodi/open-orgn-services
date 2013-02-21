@vcr 
Feature: Github monitoring

  In order to track our open-source metrics
  As a member of the tech team
  I want to capture stats from github and push them to a dashboard
  
  Scenario: get public repository count
    Given there are 16 public repositories on github
    Then the number 16 should be stored in the public repositories stat
    When the github monitor runs

  @wip
  Scenario: get open issue count
    Given the repository "open-orgn-services" has 67 open issues
    And the repository "public-displays" has 2 open issues
    And the repository "csv-profiler" has 1 open issue
    And the repository "open-data-tech-review" has 1 open issue
    Then the number 71 should be stored in the open issues stat
    When the github monitor runs

  Scenario: get watcher count
    Given the repository "open-data-tech-review" has 28 watchers
    Then the number 28 should be stored in the watchers stat
    When the github monitor runs

  Scenario: get fork count
    Given the repository "open-data-tech-review" has 4 forks
    And the repository "odibot" has 1 fork
    Then the number 5 should be stored in the forks stat
    When the github monitor runs

  Scenario: get open pull request count
    Given the repository "open-orgn-services" has 1 open pull request
    Then the number 1 should be stored in the open pull requests stat
    When the github monitor runs

  Scenario: get total pull request count
    Given the repository "open-orgn-services" has 1 open pull request
    And the repository "open-orgn-services" has 1 closed pull request
    And the repository "public-keys" has 3 closed pull requests
    And the repository "odibot" has 1 closed pull request
    Then the number 6 should be stored in the total pull requests stat
    When the github monitor runs
    
  Scenario: get outgoing pull request count
    Given the repository "waynerobinson/xeroizer" has 1 pull request from us
    Then the number 1 should be stored in the outgoing pull requests stat
    When the github monitor runs
