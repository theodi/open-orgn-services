@vcr @capsulecrm
Feature: Store membership ID in capsuleCRM
  In order to keep capsuleCRM up to date
  As a commercial team member
  I want generated member IDs to be stored back into capsuleCRM when they are created

  Scenario: Member ID should be stored
    Given there is an existing organisation in CapsuleCRM called "Weyland-Yutani Corp"
    Given that organisation has a data tag called "Membership"
    And that data tag has the following fields:
    | Level   | Email                   | ID |
    | partner | info@weyland-yutani.com |    |
    And a membership has been created for me
    When the job is run to store the membership ID back into capsule
    Then there should still be just one organisation in CapsuleCRM called "Weyland-Yutani Corp"
    And that organisation should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have the level "partner"
    And that data tag should have the email "info@weyland-yutani.com"
    And that data tag should have my new membership number set
  
  Scenario: Member ID should be stored for individuals
    Given there is an existing person in CapsuleCRM called "Arnold Rimmer" with email "rimmer@jmc.com"
    And that person has a tag called "Membership"
    And that data tag has the following fields:
    | Level      | Email          | ID |
    | individual | rimmer@jmc.com |    |
    And a membership has been created for me
    When the job is run to store the membership ID back into capsule
    Then there should still be just one person in CapsuleCRM called "Arnold Rimmer" with email "rimmer@jmc.com"
    And that person should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have the level "individual"
    And that data tag should have the email "rimmer@jmc.com"
    And that data tag should have my new membership number set