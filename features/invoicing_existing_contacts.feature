@vcr
Feature: Invoicing existing contacts

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Background:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And the event is happening on 2013-03-17
    And the net price of the event is 1.00
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"
    And I work for "Existing Company Inc."
    And there is a contact in Xero for "Existing Company Inc."

  # Invoicing basics

  Scenario: invoices are drafts
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should be a draft

  Scenario: invoices include purchase order numbers
    Given I have registered for a ticket
    And my purchase order reference is "AB1234"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the reference "AB1234"

  Scenario: invoices include membership numbers
    Given I have registered for a ticket
    And I entered a membership number "9101112"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And the line item description should include "Membership number: 9101112"

  Scenario: invoices have due date 7 days before event
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should be due on 2013-03-10

  # Invoice idempotency
  
  Scenario: invoices are not generated more than once for same purchase
    Given I have registered for a ticket
    And my order number is 1243543543
    And I paid with Paypal
    And I have already been invoiced
    When the attendee invoicer runs
    Then I should not be invoiced again

  # VAT

  Scenario: invoices have VAT added
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    # 1.00 * 1.2. Xero should add the VAT that eventbrite charged automatically.
    And that invoice should have a total of 1.20

  Scenario: invoices do not have VAT added for overseas purchasers with tax registration numbers
    Given I have registered for a ticket
    # Overseas companies only, so excluded from VAT
    And my organisation has a tax registration number "5678" 
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should have a total of 1.00

  # Line items

  Scenario: line items include order number from Eventbrite
    Given I have registered for a ticket
    And my order number is 1243543543
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And the line item description should include "1243543543"

  Scenario: line items have correct quantity for multiple tickets
    Given I have registered for two tickets
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And that line item should have a quantity of 2
    And that invoice should have a total of 2.40
    
  Scenario: line items should not have an account code
    Given I have registered for a ticket
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And that line item should not have account code set

  Scenario: line item description should include event name and date
    Given I have registered for a ticket
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And the line item description should include "[Test Event 00] Drupal: Down the Rabbit Hole (2013-03-17)"

  Scenario: line item description should include registrant name and email
    Given I have registered for a ticket
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And the line item description should include "Bob Fish <bob.fish@example.com>"

  # Payment methods
    
  Scenario: invoices show paypal payment method as fully paid
  
    We can't actually add the payment into Xero, that 
    needs to be matched up from PayPal. Instead, we add a zero-value
    line item saying that it's been paid.
  
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should show that payment has been received
    And that invoice should show that the payment was made with Paypal

  # Scenario: invoices show google checkout payment method as fully paid
  #   Given I have registered for a ticket
  #   And I paid with Google Checkout
  #   When the attendee invoicer runs
  #   Then an invoice should be raised in Xero against "Existing Company Inc."
  #   And that invoice should show that payment has been received
  #   And that invoice should show that the payment was made with Google Checkout

  Scenario: invoices to be paid later show as unpaid
    Given I have registered for a ticket
    And I requested an invoice
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should show that payment has not been received
    
