Feature: Invoicing

  In order to be invoiced for the training so that my company or government department can pay for it
  As a prospective delegate
  I want to be sent an invoice when I sign up to attend an event
  
  Scenario:
    Given there is an event in Eventbrite
    When I sign up to that event and ask to be invoiced
    Then I should be marked as wanting an invoice
    
  Scenario:
    Given I have asked to be invoiced
    Then an invoice should be raised in Xero