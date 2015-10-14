@vcr @capsulecrm @mailchimp
Feature: Manage mailing list
  In order to keep the mailing list correct
  As a commercial team member
  I want members to be subscribed or unsubscribed based on their preference automatically

  Scenario: Subscribe new members
    Given that a member has requested to be on the mailing list
    When the mailing list syncronization job runs
    Then the member will subscribed to the mailing list

  Scenario: Update members if they already exist
    Given that a member is already on the mailing list and is reprocessed
    When the mailing list syncronization job runs
    Then the members details will be updated

  Scenario: Unsubscribe members
    Given that a member has requested to NOT be on the mailing list
    And the member is already on the mailing list
    When the mailing list syncronization job runs
    Then the member will unsubscribed to the mailing list

