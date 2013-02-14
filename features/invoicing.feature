@vcr
Feature: Invoicing for training events

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
    And I entered a purchase order number "AB1234"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the reference "AB1234"

  Scenario: invoices include VAT reg numbers
    Given I have registered for a ticket
    And I entered a VAT registration number "AB5678"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the note "VAT registration number: AB5678"

  Scenario: invoices include membership numbers
    Given I have registered for a ticket
    And I entered a membership number "9101112"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the note "Membership number: 9101112"

  Scenario: invoices have due date 7 days before event
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should be due on 2013-03-10

  # Invoice idempotency
  
  Scenario: invoices are not generated more than once for same purchase
    Given I have registered for a ticket
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
    # 0.66 * 1.2. Xero should add the VAT that eventbrite charged automatically.
    And that invoice should have a total of 1.20

  Scenario: invoices do not have VAT added for overseas purchasers with VAT registration numbers
    Given I have registered for a ticket
    # Overseas companies only, so excluded from VAT
    And I entered a VAT registration number "5678" 
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should have a total of 1.00

  # Line items

  Scenario: line items have correct quantity for multiple tickets
    Given I have registered for two tickets
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should have a total of 2.40
    And that invoice should contain 1 line item
    And that line item should have a quantity of 2
    
  Scenario: line items should have 'incoming' account code
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And that line item should have account code 200

  Scenario: line items should have description
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And that line item should have the description "Registration for '[Test Event 00] Drupal: Down the Rabbit Hole (2013-03-17)' for Bob Fish <bob.fish@example.com>"

  # Payment methods
    
  Scenario: invoices show paypal payment method as fully paid
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
    
