@vcr @clean_up_xero_contact @clean_up_xero_invoice
Feature: Invoicing existing personal contacts

  In order to be invoiced for the training
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Background:
    Given the invoice is due on 2013-03-10
    And the invoice amount is 1.00
    And the invoice description is "my fantastic invoice description"
    And my first name is "Bob"
    And my last name is "Fish"
    And I have an invoice contact email of "bob.fish@example.com"
    And I do not work for anyone
    And there is a contact in Xero for "Bob Fish (bob.fish@example.com)"

  Scenario: invoices are raised
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Bob Fish (bob.fish@example.com)"

  Scenario: invoices are not generated more than once for same purchase
    Given I have registered for a ticket
    And I paid with Paypal
    And I have already been invoiced
    When the attendee invoicer runs
    Then I should not be invoiced again