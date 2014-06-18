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
    And my company has a size of "small"
    And my company is "commercial"
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

  Scenario: add signups to correct queues
    Given I requested 1 membership at the level called "supporter"
    And I requested to pay by invoice
    And my purchase order reference is "ABC000001"
    Then the invoice description should read "ODI Supporter (01010101) [Commercial]"
    And the invoice price should be "720"
    And the supporter level should be "Supporter"
    And I should be added to the invoicing queue
    And I should be added to the capsulecrm queue
    When the signup processor runs

  Scenario Outline: generate correct prices and descriptions
    Given I requested 1 membership at the level called "supporter"
    And my company has a size of "<size>"
    And my company is "<status>"
    And I requested to pay by invoice
    And my purchase order reference is "ABC000001"
    Then the invoice description should read "<description>"
    And the invoice price should be "<price>"
    And the supporter level should be "<level>"
    And I should be added to the invoicing queue
    And I should be added to the capsulecrm queue
    When the signup processor runs
    Examples:
    | size  | status         | description                                     | level               | price |
    | small | commercial     | ODI Supporter (01010101) [Commercial]           | Supporter           | 720    |
    | large | commercial     | ODI Corporate Supporter (01010101) [Commercial] | Corporate supporter | 1440   |
    | small | non_commercial | ODI Supporter (01010101) [Non Commercial]       | Supporter           | 720    |
    | large | non_commercial | ODI Supporter (01010101) [Non Commercial]       | Supporter           | 720    |


# currently an issue with leading zeros being removed from postcode and membership number
