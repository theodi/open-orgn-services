Feature: Invoicing for training events

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Background:
    Given an event in Eventbrite called "Training Course" with id 5441375300
    And the event is happening on 2012-04-14
    And the price of the event is 0.01
    And the eventbrite fee is 0.65
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"
    And I work for "Existing Company Inc."
    And there is a contact in Xero for "Existing Company Inc."

  # Invoicing basics

  Scenario:
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should be a draft

  Scenario:
    Given I have registered for a ticket
    And I entered a purchase order number "1234"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the reference "1234"

  Scenario:
    Given I have registered for a ticket
    And I entered a VAT registration number "5678"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the note "VAT registration number: 5678"

  Scenario:
    Given I have registered for a ticket
    And I entered a membership number "9101112"
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the note "Membership number: 9101112"

  Scenario:
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should be due on 2012-04-07

  # VAT

  Scenario:
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    # 0.66 * 1.2. Xero should add the VAT that eventbrite charged automatically.
    And that invoice should have a total of 0.79 

  Scenario:
    Given I have registered for a ticket
    # Overseas companies only, so excluded from VAT
    And I entered a VAT registration number "5678" 
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should have a total of 0.66

  # Line items

  Scenario:
    Given I have registered for two tickets
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should have a total of 1.584
    And that invoice should contain 1 line item
    And that line item should have a quantity of 2
    
  Scenario:
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    # ideally, we might need to change this to a default code
    And that line item should not have an account code set 

  Scenario:
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And that line item should have the description "Registration for 'Training Course (2012-04-14)' for Bob Fish <bob.fish@example.com>"

  # Payment methods
    
  Scenario:
    Given I have registered for a ticket
    And I paid with Paypal
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should show that payment has been received
    And that invoice should show that the payment was made with Paypal

  # Scenario:
  #   Given I have registered for a ticket
  #   And I paid with Google Checkout
  #   When the attendee invoicer runs
  #   Then an invoice should be raised in Xero against "Existing Company Inc."
  #   And that invoice should show that payment has been received
  #   And that invoice should show that the payment was made with Google Checkout

  Scenario:
    Given I have registered for a ticket
    And I requested an invoice
    When the attendee invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should show that payment has not been received
    
