@vcr @capsulecrm @timecop
Feature: Create opportunities and tags against organisations in CapsuleCRM

  In order to see lower-level members in our sales pipeline
  As a commercial person
  I want opportunities to be created in CapsuleCRM
  when lower-level members sign up

  Background:
    Given my name is "Turk Turkleton"
    And I work for "ACME widgets Inc."
    And my email address is "turkleton@acme.com"
    And I requested membership at the level called "supporter"
    And that it's 2013-01-01 14:35
    And my membership number is "AB1234YZ"
    And my organisation has a company number "08030289"
    And my company has a size of "<10"
    And my sector is "Healthcare"

  Scenario Outline: attach opportunities to existing organisations
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    And I requested membership at the level called "<level>"
    When I sign up via the website
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have an opportunity against it
    And that opportunity should have the name "Membership at <level> level"
    And that opportunity should have the description "Membership #: AB1234YZ"
    And that opportunity should have the milestone "Invoiced"
    And that opportunity should have the probability 100%
    And that opportunity should have the value <amount> per month for 12 month
    And that opportunity should be owned by "defaultuser"
    And that opportunity should have a type of "Membership"
    Examples:
    | level     | amount |
    | supporter | 60     |

  Scenario: attach membership tag to existing organisation
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    When I sign up via the website
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have the level "supporter"
    And that data tag should have the supporter level "Supporter"
    And that data tag should have the join date 2013-01-01
    And that data tag should have the membership number "AB1234YZ"
    And that data tag should have the size "<10"
    And that data tag should have the sector "Healthcare"
    And that data tag should have the email "turkleton@acme.com"

  Scenario: attach membership tag to new organisation
    Given there is no organisation in CapsuleCRM called "ACME widgets Inc."
    When I sign up via the website
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a data tag
    And that data tag should have the type "Membership"
    And that data tag should have the level "supporter"
    And that data tag should have the supporter level "Supporter"
    And that data tag should have the join date 2013-01-01
    And that data tag should have the membership number "AB1234YZ"
    And that data tag should have the size "<10"
    And that data tag should have the sector "Healthcare"
    And that data tag should have the email "turkleton@acme.com"

  Scenario: set company number on existing organisation
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    When I sign up via the website
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a company number "08030289"

  Scenario: Organisation search should be case insensitive
    Given there is an existing organisation in CapsuleCRM called "acme widgets Inc."
    When I sign up via the website
    Then there should still be just one organisation in CapsuleCRM called "acme widgets Inc."
    And that organisation should have a data tag
    And that organisation should have an opportunity against it
