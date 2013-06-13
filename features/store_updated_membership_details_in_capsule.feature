@vcr @capsulecrm
Feature: Store updated membership details in capsuleCRM
  In order to keep capsuleCRM up to date
  As a commercial team member
  I want changes made in the membership directory app to be stored back into capsuleCRM
  
  Background:
    Given there is an existing organisation in CapsuleCRM called "Weyland-Yutani Corp"
    Given that organisation has a data tag called "Membership"
    And that data tag has the following fields:
    | Level   | Email                   | ID       | Newsletter |
    | partner | info@weyland-yutani.com | AB1234FG | false      |

  Scenario: Membership information should be stored
    Given I have updated my membership details
    When the job is run to update my membership details in capsule
    Then there should still be just one organisation in CapsuleCRM called "Weyland-Yutani Corp"
    And that organisation should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have my updated email
    And that data tag should have my updated newsletter preferences
  
