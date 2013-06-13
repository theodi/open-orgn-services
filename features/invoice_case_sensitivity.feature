@vcr
Feature: Invoicing existing contacts with case insensitivity

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Background:
    Given the invoice is due on 2013-03-10
    And the invoice amount is 1.00
    And the invoice description is "my fantastic invoice description"
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"
    And I work for "EXISTING COMPANY INC."
    And there is a contact in Xero for "Existing Company Inc."

  Scenario: invoices are created despite case mismatch
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."