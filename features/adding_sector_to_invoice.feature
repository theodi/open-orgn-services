@vcr @clean_up_xero_contact @clean_up_xero_invoice
Feature: Adding sector to invoices

  Background:
    Given the invoice is due on 2013-03-10
    And the invoice amount is 1.00
    And the invoice description is "my fantastic invoice description"
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"
    And I work for "Existing Company Inc."
    And there is a contact in Xero for "Existing Company Inc."

  Scenario: Sector is added when user requests an invoice
    Given I have registered for a ticket
    And my purchase order reference is "AB1234"
    And my sector is "Public sector"
    And I have not already been invoiced
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the sector "Public sector"

  Scenario: Sector is added when user pays by PayPal
    Given I have registered for a ticket
    And I paid with Paypal
    And my sector is "Public sector"
    And I have not already been invoiced
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the sector "Public sector"
