@vcr @capsulecrm
Feature: Add organisation details to Capsule CRM
  
  In order for the commercial team to be able to see and update organisation details in Capsule CRM
  As a commercial person
  I want data to be inserted into Capsule CRM
  So Capsule is treated as the canonical data source
  
  Background: 
    Given I enter my organisation details
    And my membership number is "HG5646HD"

  Scenario: wait for Xero to capsule sync
   Given there is no organisation in CapsuleCRM called "The RAND Corporation"
   Then my directory entry should be requeued for later processing once the contact has synced from Xero
   When the directory entry job runs
  
  @timecop
  Scenario: attach directory entry tag to existing organisation
    Given that it's 2100-03-04 14:54
    And there is an existing organisation in CapsuleCRM called "The RAND Corporation"
    And that organisation has a data tag called "Membership"
    And that data tag has the following fields:
    | Level   | Email         | ID       |
    | partner | info@rand.com | HG5646HD |
    When the directory entry job runs
    Then there should still be just one organisation in CapsuleCRM called "The RAND Corporation"
    And that organisation should have a "DirectoryEntry" data tag
    And my details should be stored in that data tag
  
  Scenario: Updating data in Capsule
    Given there is an existing organisation in CapsuleCRM called "The RAND Corporation" with a data tag 
    And that organisation has a data tag called "Membership"
    And that data tag has the following fields:
    | Level   | Email         | ID       |
    | partner | info@rand.com | HG5646HD |
    And I change my organisation details
    When the directory entry job runs
    Then there should still be just one organisation in CapsuleCRM called "The RAND Corporation"
    And that organisation should have a "DirectoryEntry" data tag 
    And my details should be stored in that data tag
  
  @timecop
  Scenario: Updating data in Capsule when the data in Capsule is newer
    Given there is an existing organisation in CapsuleCRM called "The RAND Corporation" with a data tag 
    And that organisation has a data tag called "Membership"
    And that data tag has the following fields:
    | Level   | Email         | ID       |
    | partner | info@rand.com | HG5646HD |
    And I change my organisation details
    And that it's 2012-03-04 14:54
    When the directory entry job runs
    Then there should still be just one organisation in CapsuleCRM called "The RAND Corporation"
    And that organisation should have a "DirectoryEntry" data tag
    And my original details should still be stored in that data tag