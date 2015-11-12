@vcr @capsulecrm
Feature: Synchronize a single updated person
  In order to keep the member directory up to date
  As a commercial team member
  I want my changes in CapsuleCRM to be reflected in the members directory

  Scenario: Send updated organization data to observer without directory entry
    Given there is an existing person in CapsuleCRM called "Arnold Rimmer" with email "rimmer@jmc.com"
    And that person has a tag called "Membership"
    And that data tag has the following fields:
    | Level      | Email        | ID            | Newsletter |
    | individual | info@ocp.com | AB1234YZ      | true       |
    And an observer object has been registered
    Then the observer should be notified with the person's information
    When the capsule sync job for that person runs

