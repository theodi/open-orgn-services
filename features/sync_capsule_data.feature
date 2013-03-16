@vcr @capsulecrm
Feature: Synchronize a single updated organisation
  In order to keep the member directory up to date
  As a commercial team member
  I want my changes in CapsuleCRM to be reflected in the members directory
  
  Background:
    Given there is an existing organisation in CapsuleCRM called "Omni Consumer Products"
    And that organisation has a data tag called "Membership"
    And that data tag has the following fields:
    | Level   | Email        |
    | partner | info@ocp.com |

  Scenario: Send updated organization data to observer without directory entry
    Given an observer object has been registered
    Then the observer should be notified with the organisation's information
    When the capsule sync job for that organisation runs
  
  Scenario: Send updated organization data to observer with directory entry
    Given that organisation has a data tag called "DirectoryEntry"
    And that data tag has the following fields:
    | Description          | Homepage       | Active |
    | 20 seconds to comply | http://ocp.com | true   |
    And an observer object has been registered
    Then the observer should be notified with the organisation's information
    When the capsule sync job for that organisation runs

