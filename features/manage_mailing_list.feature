@capsulecrm @mailchimp
Feature: Manage mailing list
  In order to keep the mailing list correct
  As a commercial team member
  I want members to be subscribed or unsubscribed based on their preference automatically

  Scenario: Subscribe members updated in the last 24 hours
    Given that a member has requested to be on the mailing list in the 24 hours
    When the mailing list syncronization job runs
    Then the member will subscribed to the mailing list

  Scenario: Unsubscribe members updated in the last 24 hours
    Given that a member has requested to NOT be on the mailing list in the 24 hours
    And the member is already on the mailing list
    When the mailing list syncronization job runs
    Then the member will unsubscribed to the mailing list

