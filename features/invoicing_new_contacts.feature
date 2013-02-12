Feature: Invoicing for training events

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Background:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And the price of the event is 1.00
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"

  # Creation of Xero contacts

  Scenario:
    Given I do not work for anyone
    And there is no contact in Xero for "Bob Fish"
    And I have registered for a ticket
    When the attendee invoicer runs
    Then a contact should be created in Xero for "Bob Fish"
    And an invoice should be raised in Xero against "Bob Fish"

  Scenario:
    Given I work for "New Company Inc."
    And there is no contact in Xero for "New Company Inc."
    And I have registered for a ticket
    When the attendee invoicer runs
    Then a contact should be created in Xero for "New Company Inc."
    And an invoice should be raised in Xero against "New Company Inc."
    
  # Storing of invoice-to details
    
  Scenario:
    Given I work for "New Company Inc."
    And that company has a invoice contact email of "finance@newcompany.com"
    And that company has a invoice phone number of "01234 5678910"
    And that company has a invoice address of "123 Random Business Park, London, UK" 
    And there is no contact in Xero for "New Company Inc."
    And I have registered for a ticket
    When the attendee invoicer runs
    Then a contact should be created in Xero for "New Company Inc."
    And that contact should have email "finance@newcompany.com"
    And that contact should have phone number "01234 5678910"
    And that contact should have address "123 Random Business Park, London, UK"