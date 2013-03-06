@vcr @capsulecrm @timecop
Feature: Create opportunities and tags against organisations in CapsuleCRM

  In order to see lower-level members in our sales pipeline
  As a commercial person
  I want opportunities to be created in CapsuleCRM 
  when lower-level members sign up

  Background:
    Given my name is "Turk Turkleton"
    And I work for "ACME widgets Inc."
    And I requested membership at the level called "supporter"
    And that it's 2013-01-01 14:35
    And my membership number is "AB1234YZ"

  Scenario: wait for Xero to capsule sync
    Given there is no organisation in CapsuleCRM called "ACME widgets Inc."
    Then my signup should be requeued for later processing once the contact has synced from Xero
    When I sign up via the website

  Scenario Outline: attach opportunities to existing organisations
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    And I requested membership at the level called "<level>"
    When I sign up via the website
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have an opportunity against it
    And that opportunity should have the name "Membership at <level> level"
    And that opportunity should have the description "Membership #: AB1234YZ"
    And that opportunity should have the milestone "Won"
    And that opportunity should have the probability 100%
    And that opportunity should have the value <amount> per month for 12 month
    And that opportunity should be owned by "defaultuser"
    And that opportunity should have a type of "Membership"
    Examples:
    | level     | amount |
    | supporter | 45     |
    | member    | 400    |

  Scenario: attach tag to existing organisation
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    When I sign up via the website
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have the level "supporter"
    And that data tag should have the join date 2013-01-01
    And that data tag should have the membership number "AB1234YZ"
