@vcr @wip
Feature: Processing membership signups

  In order to make sure that new member signups are managed properly in ODI systems
  As a membership programme manager
  I want something to process all membership signups

    # In many of these scenarios, we are using the order Given/Then/When, rather than
    # Given/When/Then. This is intentional, and lets us set up Resque expectations in
    # a better way in the steps.

  Background:
    Given my email address is "bob.fish@example.com"
    And my first name is "Bob"
    And my last name is "Fish"
    And I have an invoice contact email of "finance@newcompany.com"
    And I have an invoice phone number of "01234 5678910"
    And I have an invoice address (line1) of "123 Random Business Park"
    And I have an invoice address (line2) of "The Rough End"
    And I have an invoice address (city) of "London"
    And I have an invoice address (region) of "Greater London"
    And I have an invoice address (country) of "UK" 
    And I have an invoice address (postcode) of "EC1A 1AA" 
    And I have a membership number "9101112"

  Scenario: add users to new style invoicing queue
    Given a membership level called "supporter" which has a base annual cost of 1000
    And my purchase order number is 142052968
    Then I should be added to the new style invoicing queue
    When the signup processor runs


# add description to the scenario
# add scenarios for different membership levels


#    And I work for "New Company Inc."
#    And I entered a tax registration number "AB5678"
#    And I entered a purchase order number "AB1234"