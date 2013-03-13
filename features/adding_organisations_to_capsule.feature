@vcr @capsulecrm
Feature: Add organisation details to Capsule CRM
  
  In order for the commercial team to be able to see and update organisation details in Capsule CRM
  As a commercial person
  I want data to be inserted into Capsule CRM
  So Capsule is treated as the canonical data source
  
  Background: 
    Given my organisation name is "The RAND Corporation"
    And my description is "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    And my organisation homepage is "http://www.example.com"
    And my organisation logo (original) is stored at "http://stuff.theodi.org/images/acmelogo.png"
    And my organisation logo (thumbnail) is stored at "http://stuff.theodi.org/images/thumbs/acmelogo.png"
    And my membership number is "AB1234YZ"

  Scenario: wait for Xero to capsule sync
   Given there is no organisation in CapsuleCRM called "The RAND Corporation"
   Then my directory entry should be requeued for later processing once the contact has synced from Xero
   When I enter my organisation details
    
  Scenario: attach directory entry tag to existing organisation
    Given there is an existing organisation in CapsuleCRM called "The RAND Corporation"
    When I enter my organisation details
    Then there should still be just one organisation in CapsuleCRM called "The RAND Corporation"
    And that organisation should have a data tag
    And that data tag should have the type "DirectoryEntry"
    And that data tag should have a description "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    And that data tag should have an organisation homepage "http://www.example.com"
    And that data tag should have a logo url of "http://stuff.theodi.org/images/acmelogo.png"
    And that data tag should have a thumbnail url of "http://stuff.theodi.org/images/thumbs/acmelogo.png"