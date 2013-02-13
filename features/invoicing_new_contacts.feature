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

  # Creation of Xero contacts and requeuing of jobs

  @clean_up_xero_contact
  Scenario:
    Given I do not work for anyone
    And there is no contact in Xero for "Bob Fish"
    And I have registered for a ticket
    Then the attendee invoicer should be requeued
    When the attendee invoicer runs
    Then a contact should exist in Xero for "Bob Fish"

  @clean_up_xero_contact
  Scenario:
    Given I work for "New Company Inc."
    And there is no contact in Xero for "New Company Inc."
    And I have registered for a ticket
    Then the attendee invoicer should be requeued
    When the attendee invoicer runs
    Then a contact should exist in Xero for "New Company Inc."
    
  # Storing of invoice-to details
  
  @clean_up_xero_contact
  Scenario:
    Given I work for "New Company Inc."
    And my address is "29 Acacia Road"
    And my city is "Dandytown"
    And my country is "UK"
    And that company has an invoice contact email of "finance@newcompany.com"
    And that company has an invoice phone number of "01234 5678910"
    And that company has an invoice address of "123 Random Business Park"
    And that company has an invoice city of "London"
    And that company has an invoice country of "UK" 
    And there is no contact in Xero for "New Company Inc."
    And I have registered for a ticket
    When the attendee invoicer runs
    Then a contact should exist in Xero for "New Company Inc."
    And that contact should have email "finance@newcompany.com"
    And that contact should have phone number "01234 5678910"
    And that contact should have street address (line1) of "29 Acacia Road"
    And that contact should have street address (city) of "Dandytown"
    And that contact should have street address (country) of "UK"
    And that contact should have postal address (line1) of "123 Random Business Park"
    And that contact should have postal address (city) of "London"
    And that contact should have postal address (country) of "UK"
    
  @clean_up_xero_contact
  Scenario:
    Given I do not work for anyone
    And my phone number is "01234 098765"
    And my address is "29 Acacia Road"
    And my city is "Dandytown"
    And my country is "UK"
    And there is no contact in Xero for "Bob Fish"
    And I have registered for a ticket
    When the attendee invoicer runs
    Then a contact should exist in Xero for "Bob Fish"
    And that contact should have email "bob.fish@example.com"
    And that contact should have phone number "01234 098765"
    And that contact should have postal address (line1) of "29 Acacia Road"
    And that contact should have postal address (city) of "Dandytown"
    And that contact should have postal address (country) of "UK"