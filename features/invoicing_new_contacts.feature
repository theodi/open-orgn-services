@vcr @clean_up_xero_contact
Feature: Invoicing new contacts for training events

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Background:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And the net price of the event is 1.00
    And my first name is "Bob"
    And my last name is "Fish"
    And I have an invoice contact email of "bob.fish@example.com"

  # Creation of Xero contacts and requeuing of jobs

  Scenario: personal contact creation
    Given I do not work for anyone
    And there is no contact in Xero for "Bob Fish <bob.fish@example.com>"
    And I have registered for a ticket
    Then the attendee invoicer should be requeued
    When the attendee invoicer runs
    Then a contact should exist in Xero for "Bob Fish <bob.fish@example.com>"

  Scenario: company contact creation
    Given I work for "New Company Inc."
    And there is no contact in Xero for "New Company Inc."
    And I have registered for a ticket
    Then the attendee invoicer should be requeued
    When the attendee invoicer runs
    Then a contact should exist in Xero for "New Company Inc."
    
  # tax registration numbers for overseas companies
  
  Scenario: store tax numbers for contacts
    Given I work for "New Company Inc."
    And there is no contact in Xero for "New Company Inc."
    And I have registered for a ticket
    And my organisation has a tax registration number "AB5678"
    Then the attendee invoicer should be requeued
    When the attendee invoicer runs
    Then a contact should exist in Xero for "New Company Inc."
    And that contact should have tax number "AB5678"
    
  # Storing of invoice-to details
  
  Scenario: store company 'invoice to' details
    Given I work for "New Company Inc."
    And that company has an invoice contact email of "finance@newcompany.com"
    And that company has an invoice phone number of "01234 5678910"
    And that company has an invoice address (line1) of "123 Random Business Park"
    And that company has an invoice address (line2) of "The Rough End"
    And that company has an invoice address (city) of "London"
    And that company has an invoice address (region) of "Greater London"
    And that company has an invoice address (country) of "UK" 
    And that company has an invoice address (postcode) of "EC1A 1AA" 
    And there is no contact in Xero for "New Company Inc."
    And I have registered for a ticket
    Then the attendee invoicer should be requeued    
    When the attendee invoicer runs
    Then a contact should exist in Xero for "New Company Inc."
    And that contact should have email "finance@newcompany.com"
    And that contact should have phone number "01234 5678910"
    And that contact should have postal address (line1) of "123 Random Business Park, The Rough End"
    And that contact should have postal address (city) of "London"
    And that contact should have postal address (region) of "Greater London"
    And that contact should have postal address (country) of "UK"
    And that contact should have postal address (postal_code) of "EC1A 1AA"