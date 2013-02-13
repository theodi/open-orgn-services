Feature: Trello monitoring

  In order to track our housekeeping queue
  As a member of the tech team
  I want to capture stats from Trello and push them to a dashboard
  
  Scenario:
    Given there are 41 cards on the To Do list on Trello
    Given there are 12 cards on the Doing list on Trello
    Then the number 53 should be stored in the housekeeping graph stat
    When the trello monitor runs