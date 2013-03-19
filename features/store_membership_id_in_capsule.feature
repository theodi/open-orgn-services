@vcr @capsulecrm
Feature: Store membership ID in capsuleCRM
  In order to keep capsuleCRM up to date
  As a commercial team member
  I want generated member IDs to be stored back into capsuleCRM when they are created
  
  Background:
    Given there is an existing organisation in CapsuleCRM called "Weyland-Yutani Corp"
    Given that organisation has a data tag called "Membership"
    And that data tag has the following fields:
    | Level   | Email                   | ID |
    | partner | info@weyland-yutani.com |    |

  Scenario: Member ID should be stored
    Given a membership has been created for me
    When the job is run to store the membership ID back into capsule
    Then there should still be just one organisation in CapsuleCRM called "Weyland-Yutani Corp"
    And that organisation should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have the level "partner"
    And that data tag should have the email "info@weyland-yutani.com"
    And that data tag should have my new membership number set
  
