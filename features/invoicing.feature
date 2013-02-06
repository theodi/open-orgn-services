Feature: Invoicing

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event
  
  Scenario:
    Given there is an event in Eventbrite with id 5441375300
    When 'james.smith@theodi.org' signs up to that event and asks to be invoiced
    Then he should be added to the invoicing queue
    
  Scenario:
    Given there is an event in Eventbrite with id 5441375300
    When 'sam.pikesley@theodi.org' signs up to that event and gets a free ticket
    Then he should not be added to the invoicing queue

  Scenario:
    Given 'james.smith@theodi.org' needs to be invoiced for 0.66
    Then an invoice should be raised in Xero