@vcr
Feature: Trello monitoring

  In order to track our housekeeping queue
  As a member of the tech team
  I want to capture stats from Trello and push them to a dashboard
  
  Scenario: trello housekeeping graph
    Given there are 46 cards on the To Do list on Trello
    Given there are 11 cards on the Doing list on Trello
    Then the number 57 should be stored in the housekeeping graph stat
    When the trello monitor runs