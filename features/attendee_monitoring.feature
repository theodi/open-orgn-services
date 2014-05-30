@vcr
Feature: Monitoring attendee signups

  In order to make sure that all event attendees are managed propery in ODI systems
  As a training manager
  I want something to monitor all attendee signups

	# In many of these scenarios, we are using the order Given/Then/When, rather than
	# Given/When/Then. This is intentional, and lets us set up Resque expectations in
	# a better way in the steps.

  Background:
    Given an event in Eventbrite called "[Test Event 00] Drupal: Down the Rabbit Hole" with id 5441375300
    And that event starts at 2013-03-17 19:00
    And my email address is "bob.fish@example.com"
    And my first name is "Bob"
    And my last name is "Fish"
    And my phone number is "01234 098765"
    And my address (line1) is "29 Acacia Road"
    And my address (line2) is "The Posh End"
    And my address (city) is "Dandytown"
    And my address (region) is "Berkshire"
    And my address (country) is "GB"
    And my address (postcode) is "NT4 3HG"
    And I work for "New Company Inc."
    And that company has an invoice contact email of "finance@newcompany.com"
    And that company has an invoice phone number of "01234 5678910"
    And that company has an invoice address (line1) of "123 Random Business Park"
    And that company has an invoice address (line2) of "The Rough End"
    And that company has an invoice address (city) of "London"
    And that company has an invoice address (region) of "Greater London"
    And that company has an invoice address (country) of "UK"
    And that company has an invoice address (postcode) of "EC1A 1AA"
    And my organisation has a tax registration number "AB5678"
    And I entered a membership number "9101112"
    And my purchase order reference is "AB1234"
    And my sector is "Public sector"
    And I requested an invoice
	Then the invoice should be due on 2013-03-10

  Scenario: add users to invoicing queue if they have a paid ticket
    Given I have signed up for 2 tickets called "Cheap Ticket" which has a net price of 1.00
    And my order number is 142052968
	Then the invoice description should read "Registration for '[Test Event 00] Drupal: Down the Rabbit Hole (2013-03-17)' for Bob Fish <bob.fish@example.com> (Order number: 142052968,Membership number: 9101112)"
    And I should be added to the invoicing queue along with others
    When the attendee monitor runs

  Scenario: don't add users to invoicing queue if they have a free ticket
    Given I have signed up for 1 ticket called "Free Ticket" which has a net price of 0.00
    And my order number is 142055824
	Then the invoice description should read "Registration for '[Test Event 00] Drupal: Down the Rabbit Hole (2013-03-17)' for Bob Fish <bob.fish@example.com> (Order number: 142055824,Membership number: 9101112)"
    And I should not be added to the invoicing queue
    When the attendee monitor runs

  # Payment types
  Scenario: pay via Paypal
    Given I have signed up for 1 ticket called "Cheap Ticket" which has a net price of 1.00
    And I paid with Paypal
    And my order number is 142059188
	Then the invoice description should read "Registration for '[Test Event 00] Drupal: Down the Rabbit Hole (2013-03-17)' for Bob Fish <bob.fish@example.com> (Order number: 142059188,Membership number: 9101112)"
    And I should be added to the invoicing queue along with others
    When the attendee monitor runs

  Scenario: pay with invoice
    Given I have signed up for 2 tickets called "Cheap Ticket" which has a net price of 1.00
    And I requested an invoice
    And my order number is 142052968
	Then the invoice description should read "Registration for '[Test Event 00] Drupal: Down the Rabbit Hole (2013-03-17)' for Bob Fish <bob.fish@example.com> (Order number: 142052968,Membership number: 9101112)"
    And I should be added to the invoicing queue along with others
    When the attendee monitor runs

  # VAT

  Scenario: invoices are raised net of VAT
    Given I have signed up for 1 ticket called "Cheap Ticket" which has a net price of 1.00
    And the gross price of the event in Eventbrite is 1.20
    And I paid with Paypal
    And my order number is 142059188
	Then the invoice description should read "Registration for '[Test Event 00] Drupal: Down the Rabbit Hole (2013-03-17)' for Bob Fish <bob.fish@example.com> (Order number: 142059188,Membership number: 9101112)"
    And I should be added to the invoicing queue along with others
    When the attendee monitor runs
