@vcr
Feature: Hubot monitoring

  In order to track our IRC users
  As a member of the tech team
  I want to capture stats from Hubot and push them to a dashboard
  
  Scenario: count people in IRC
    Given there are 5 people in IRC
    Then the following data should be stored in the "irc-theodi-users" metric
      """
      5
      """
    When the hubot monitor runs