@vcr @capsulecrm @timecop
Feature: Add person details to Capsule CRM

  In order for the commercial team to be able to see and update person details in Capsule CRM
  As a commercial person
  I want data to be inserted into Capsule CRM
  So Capsule is treated as the canonical data source

  Background:
    Given I have signed up as an individual member
    And I am paying by "credit_card"
    And I want to pay on an "annual" basis
    And my payment reference is "cus_12345"
    And my membership number is "HG5646HD"
    And my sector is "Healthcare"

  Scenario: wait for Xero to capsule sync
    Given there is no person in CapsuleCRM called "Arnold Rimmer"
    Then my directory entry should be requeued for later processing once the contact has synced from Xero
    When the directory entry job runs

  Scenario: attach membership tag to existing person
    Given I requested 1 membership at the level called "individual"
    And there is an existing person in CapsuleCRM called "Arnold Rimmer" with email "rimmer@jmc.com"
    And that it's 2013-01-01 14:35
    When I sign up via the website
    Then there should still be just one person in CapsuleCRM called "Arnold Rimmer" with email "rimmer@jmc.com"
    And that person should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have the level "individual"
    And that data tag should have the join date 2013-01-01
    And that data tag should have the membership number "HG5646HD"
    And that data tag should have the sector "Healthcare"
    And that data tag should have the email "rimmer@jmc.com"
