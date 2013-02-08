Feature: Invoicing for training events

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event

  Scenario:
    Given there is an event in Eventbrite with id 5441375300
    And 'james.smith@theodi.org' needs to be invoiced for 0.66
    And 'james.smith@theodi.org' already exists as a contact in Xero
    When the attendee invoicer runs
    Then an invoice should be added to his account

  Scenario:
    Given there is an event in Eventbrite with id 5441375300
    And 'tom.heath@theodi.org' needs to be invoiced for 0.66
    And 'tom.heath@theodi.org' does not already exist as a contact in Xero
    When the attendee invoicer runs
    Then a Xero contact should be created for Tom
    And an invoice should be added to his account

  Scenario:
    Given there is an event in Eventbrite with id 5441375300
    And 'james.smith@theodi.org' needs to be invoiced for 0.66
    And 'james.smith@theodi.org' already exists as a contact in Xero
    And an invoice already exists for the Eventbrite event with id 5441375300
    When the attendee invoicer runs
    Then the total number of invoices on his account should not increase