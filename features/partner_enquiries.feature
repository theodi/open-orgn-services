@vcr @capsulecrm @timecop
Feature: Raise tasks and opportunities in CapsuleCRM for higher-level memberships

  In order to get higher-level members in
  As a commercial person
  I want opportunities to be created in CapsuleCRM
  when interested parties fill in the web form

  Background:
    Given my name is "Turk Turkleton"
    And I work for "ACME widgets Inc."
    And my job title is "CTO"
    And my email address is "turkleton@acme.com"
    And my phone number is "+44 1738 494032"
    And my interest is "Hey, I really want us to join the ODI!"
    And I requested membership at the level called "partner"

  Scenario: Create new organisation and person
    Given there is no organisation in CapsuleCRM called "ACME widgets Inc."
    When I have asked to be contacted
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a person
    And that person should have the first name "Turk"
    And that person should have the last name "Turkleton"
    And that person should have the job title "CTO"
    And that person should have the email address "turkleton@acme.com"
    And that person should have the telephone number "+44 1738 494032"

  Scenario: Create new person in existing organisation
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation does not have a person
    When I have asked to be contacted
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a person
    And that person should have the first name "Turk"
    And that person should have the last name "Turkleton"
    And that person should have the job title "CTO"
    And that person should have the email address "turkleton@acme.com"
    And that person should have the telephone number "+44 1738 494032"

  Scenario: Update person in existing organisation
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation has a person called "Turk Turkleton"
    When I have asked to be contacted
    Then there should still be just one organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have just one person
    And that person should have the first name "Turk"
    And that person should have the last name "Turkleton"
    And that person should have the job title "CTO"
    And that person should have the email address "turkleton@acme.com"
    And that person should have the telephone number "+44 1738 494032"

  Scenario Outline: Create opportunities against organisations
    Given that it's 2013-02-01 13:45
    And I requested membership at the level called "<level>"
    When I have asked to be contacted
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have an opportunity against it
    And that opportunity should have the name "Membership at <level> level"
    And that opportunity should have the description "Hey, I really want us to join the ODI!"
    And that opportunity should have the value <amount> per year for 3 years
    And that opportunity should have the milestone "Prospect"
    And that opportunity should have the probability 10%
    And that opportunity should have an expected close date of 2013-04-01
    And that opportunity should be owned by "defaultuser"
    And that opportunity should have a type of "Membership"

    Examples:
    | level    | amount |
    | sponsor  | 25000  |
    | partner  | 50000  |

  Scenario: Create task against person
    Given that it's 2013-02-01 13:45
    When I have asked to be contacted
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a person
    And that person should have a task against him
    And that task should have the description "Call Turk Turkleton to discuss partner membership"
    And that task should be due at 2013-02-02 09:00
    And that task should have the category "Call"
    And that task should be assigned to "defaultuser"
    And that task should have the detailed description "Hey, I really want us to join the ODI!"
