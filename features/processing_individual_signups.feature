@vcr
Feature: Processing individual membership signups

  Background:
    Given my name is "Joe Nerd"
    And my email address is "joe@nerd.eg"
    And my sector is "Healthcare"
    And I have an invoice contact email of "finance@nerd.eg"
    And I have an invoice phone number of "+1 1010 101010"
    And I have an invoice address (line1) of "01 Geek Street, Techington"
    And I have an invoice address (city) of "Austin"
    And I have an invoice address (region) of "Techsus"
    And I have an invoice address (country) of "USA"
    And I have an invoice address (postcode) of "01010"
    And I have a membership id "01010101"

  Scenario: add signups to correct queues
    Given I requested 1 membership at the level called "individual"
    And I am paying by "credit_card"
    And I want to pay on an "annual" basis
    And my payment reference is "cus_12345"
    Then the invoice description should read "ODI Individual supporter (01010101) [Individual] (annual card payment)"
    And the invoice price should be "90"
    And the invoice discount should be empty
    And the supporter level should be "Individual"
    And I should be added to the invoicing queue
    When the signup processor runs

  Scenario: Add signups with discount to the correct queues
    Given I requested 1 membership at the level called "individual"
    And I am paying by "credit_card"
    And I want to pay on an "annual" basis
    And my payment reference is "cus_12345"
    Then the invoice description should read "ODI Individual supporter (01010101) [Individual] (annual card payment)"
    And the invoice price should be "90"
    And the invoice discount should be "50%"
    And the supporter level should be "Individual"
    And I should be added to the invoicing queue
    When the signup processor runs

  Scenario: Add signups with flexible pricing to the correct queues
    Given I requested 1 membership at the level called "individual"
    And I am paying by "credit_card"
    And I paid "5"
    And I want to pay on an "annual" basis
    And my payment reference is "cus_12345"
    Then the invoice description should read "ODI Individual supporter (01010101) [Individual] (annual card payment)"
    And the invoice price should be "5"
    And the supporter level should be "Individual"
    And I should be added to the invoicing queue
    When the signup processor runs

  @capsulecrm
  Scenario: add contact details to CapsuleCRM
    Given I requested 1 membership at the level called "individual"
    When the signup processor runs
    Then my contact details should exist in CapsuleCRM
