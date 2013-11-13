@vcr @clean_up_xero_contact @clean_up_xero_invoice
Feature: Invoicing existing contacts with removal of extraneous spaces

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Scenario: invoices are created despite extra spaces
    Given the invoice is due on 2013-03-10
    And the invoice amount is 1.00
    And the invoice description is "my fantastic invoice description"
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"
    And I work for " Existing Company Inc. "
    And there is a contact in Xero for "Existing Company Inc."
    And I have not already been invoiced
    And I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    
  Scenario: invoice names with two spaces should be squeezed
    Given my first name is "Bob "
    And my last name is "Fish"
    And I have an invoice contact email of "bob.fish@example.com"
    When my contact name is generated
    Then the generated name should be "Bob Fish (bob.fish@example.com)"
