@wip @vcr @clean_up_capsule
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
    And the partner enquiry processor runs
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a person called "Turk Turkleton"
    And that person should have the job title "CTO"
    And that person should have the email address "turkleton@acme.com"
    And that person should have the telephone number "+44 1738 494032"

  Scenario: Create new person in existing organisation
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation does not have a person called "Turk Turkleton"
    When I have asked to be contacted
    And the partner enquiry processor runs
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a person called "Turk Turkleton"
    And that person should have the job title "CTO"
    And that person should have the email address "turkleton@acme.com"
    And that person should have the telephone number "+44 1738 494032"

  Scenario: Update person in existing organisation
    Given there is an existing organisation in CapsuleCRM called "ACME widgets Inc."
    And that organisation has a person called "Turk Turkleton"
    When I have asked to be contacted
    And the partner enquiry processor runs
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a person called "Turk Turkleton"
    And that person should have the job title "CTO"
    And that person should have the email address "turkleton@acme.com"
    And that person should have the telephone number "+44 1738 494032"

  Scenario: Create sponsor opportunity against organisation
    Given I requested membership at the level called "sponsor"
    When I have asked to be contacted
    And the partner enquiry processor runs
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have an opportunity against it
    And that opportunity should have the name "Membership at sponsor level"
    And that opportunity should have the description "Hey, I really want us to join the ODI!"
    And that opportunity should have the value £25000 per year for 3 years
    And that opportunity should have the milestone "New"
    And that opportunity should have the probability 10%
    And that opportunity should have an expected close date 2 months from today
    And that opportunity should be owned by "defaultuser"

  Scenario: Create partner opportunity against organisation
    Given I requested membership at the level called "partner"
    When I have asked to be contacted
    And the partner enquiry processor runs
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have an opportunity against it
    And that opportunity should have the name "Membership at partner level"
    And that opportunity should have the description "Hey, I really want us to join the ODI!"
    And that opportunity should have the value £50000 per year for 3 years
    And that opportunity should have the milestone "New"
    And that opportunity should have the probability 10%
    And that opportunity should have an expected close date 2 months from today
    And that opportunity should be owned by "defaultuser"

  Scenario: Create task against person
    Given it is 2013-02-01
    When I have asked to be contacted
    And the partner enquiry processor runs
    Then an organisation should exist in CapsuleCRM called "ACME widgets Inc."
    And that organisation should have a person called "Turk Turkleton"
    And that person should have a task against him
    And that task should have the description "Call Turk Turkleton to discuss partner membership"
    And that task should be due at 2013-02-02 09:00
    And that task should have the category "Call"
    And that task should be assigned to "defaultuser"
    And that task should have the detailed description "Hey, I really want us to join the ODI!"
