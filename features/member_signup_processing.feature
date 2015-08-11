@vcr
Feature: Processing membership signups

  In order to make sure that new member signups are managed properly in ODI systems
  As a membership programme manager
  I want something to process all membership signups

    # In many of these scenarios, we are using the order Given/Then/When, rather than
    # Given/When/Then. This is intentional, and lets us set up Resque expectations in
    # a better way in the steps.

  Background:
    Given my name is "Joe Nerd"
    And my email address is "joe@nerd.eg"
    And I work for "Nerd Enterprises Inc"
    And my company has a size of "<10"
    And my company is "commercial"
    And my sector is "Healthcare"
    And I have an invoice contact email of "finance@nerd.eg"
    And I have an invoice phone number of "+1 1010 101010"
    And I have an invoice address (line1) of "01 Geek Street, Techington"
    And I have an invoice address (city) of "Austin"
    And I have an invoice address (region) of "Techsus"
    And I have an invoice address (country) of "USA"
    And I have an invoice address (postcode) of "01010"
    And my organisation has a tax registration number "A0A0A0A0"
    And my organisation has a company number "08030289"
    And I have a membership id "01010101"

  Scenario: add signups to invoicing queue
    Given I requested 1 membership at the level called "supporter"
    And I am paying by "invoice"
    And I want to pay on an "annual" basis
    And my purchase order reference is "ABC000001"
    Then the invoice description should read "ODI Supporter (01010101) [Commercial] (annual invoice payment)"
    And the invoice price should be "720"
    And the invoice discount should be empty
    And the supporter level should be "Supporter"
    And I should be added to the invoicing queue
    When the signup processor runs

  @capsulecrm
  Scenario: add contact details to CapsuleCRM
    Given I requested 1 membership at the level called "supporter"
    And the signup processor runs
    Then my organisation contact details should exist in CapsuleCRM

  Scenario Outline: generate correct prices and descriptions
    Given I requested 1 membership at the level called "supporter"
    And my company has a size of "<size>"
    And my company is "<status>"
    And I am paying by "invoice"
    And I want to pay on an "annual" basis
    And my purchase order reference is "ABC000001"
    Then the invoice description should read "<description>"
    And the invoice price should be "<price>"
    And the invoice discount should be empty
    And the supporter level should be "<level>"
    And I should be added to the invoicing queue
    When the signup processor runs
    Examples:
    | size     | status         | description                                                              | level               | price |
    | <10      | commercial     | ODI Supporter (01010101) [Commercial] (annual invoice payment)           | Supporter           | 720    |
    | >1000    | commercial     | ODI Corporate Supporter (01010101) [Commercial] (annual invoice payment) | Corporate supporter | 2200   |
    | 51-250   | non_commercial | ODI Supporter (01010101) [Non Commercial] (annual invoice payment)       | Supporter           | 720    |
    | 251-1000 | non_commercial | ODI Supporter (01010101) [Non Commercial] (annual invoice payment)       | Supporter           | 720    |

  Scenario Outline: handle payment methods and frequencies
    Given I requested 1 membership at the level called "supporter"
    And my company has a size of "10-50"
    And my company is "commercial"
    And my purchase order reference is "ABC000001"
    And I am paying by "<method>"
    And I want to pay on a "<period>" basis
    And my payment reference is "<reference>"
    Then the invoice description should read "<description>"
    And the invoice price should be "720"
    And the invoice discount should be empty
    And the supporter level should be "Supporter"
    And I should be added to the invoicing queue
    When the signup processor runs
    Examples:
    | method       | period  | reference | description                                                    |
    | invoice      | annual  |           | ODI Supporter (01010101) [Commercial] (annual invoice payment) |
    | invoice      | monthly |           | ODI Supporter (01010101) [Commercial] (annual invoice payment) |
    | credit_card  | annual  | cus_12345 | ODI Supporter (01010101) [Commercial] (annual card payment)    |
    | credit_card  | monthly | cus_54321 | ODI Supporter (01010101) [Commercial] (monthly card payment)   |
    | direct_debit | annual  | dd_32415  | ODI Supporter (01010101) [Commercial] (annual dd payment)      |
    | direct_debit | monthly | dd_32104  | ODI Supporter (01010101) [Commercial] (monthly dd payment)     |


# currently an issue with leading zeros being removed from postcode and membership number
