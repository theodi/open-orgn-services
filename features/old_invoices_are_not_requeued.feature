@vcr @clean_up_xero_contact @clean_up_xero_invoice
Feature: Old Invoices are not requeued

  In order to stop spamming Xero with pointless requests
  As a developer
  I only want unraised Invoices to be passed to the invoicer
  
  Background:
    Given the invoice is due on 2013-03-10
    And the invoice amount is 1.00
    And the invoice description is "my fantastic invoice description"
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"
    And I work for "EXISTING COMPANY INC."
    And there is a contact in Xero for "Existing Company Inc."
  
  Scenario: invoices that have already been raised are not requeued
    Given I have registered for a ticket
    And I have been sent an invoice
    And the attendee invoicer runs
    Then my registration should not be sent to Xero
    
  Scenario: invoices that have already been raised but don't have a uid set are not requeued
    Given I have registered for a ticket
    And I have been sent an invoice
    And a uid has not been set
    And the attendee invoicer runs
    And a uid is set
    Then my registration should not be sent to Xero