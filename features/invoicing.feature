@vcr @clean_up_xero_contact @clean_up_xero_invoice
Feature: Invoicing
  In order to keep track of customer purchases
  As an administrator
  I want invoices to be created

  Background:
    Given the invoice is due on 2013-03-10
    And the invoice amount is 1.00
    And my first name is "Bob"
    And my last name is "Fish"
    And my email address is "bob.fish@example.com"
    And I work for "Existing Company Inc."
    And there is a contact in Xero for "Existing Company Inc."

  Scenario: Invoices are drafts
    Given I have made a purchase
    And I paid with Paypal
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should be a draft
    And there should be 2 line items

  Scenario: Invoices include purchase order numbers
    Given I have made a purchase
    And my purchase order reference is "AB1234"
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should include the reference "AB1234"
    And there should be 1 line items

  Scenario: Invoices have correct due date
    Given I have made a purchase
    And I paid with Paypal
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should be due on 2013-03-10

  Scenario: Invoices are not generated more than once for same purchase
    Given I have made a purchase
    And I paid with Paypal
    And I have already been invoiced
    When the invoicer runs
    Then I should not be invoiced again

  Scenario: Invoices have VAT added
    Given I have made a purchase
    And I paid with Paypal
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    # 1.00 * 1.2. Xero should add the VAT that eventbrite charged automatically.
    And that invoice should have a total of 1.20

  Scenario: Invoices do not have VAT added for overseas purchasers with tax registration numbers
    Given I have made a purchase
    # Overseas companies only, so excluded from VAT
    And my organisation has a tax registration number "5678"
    And I paid with Paypal
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should have a total of 1.00

  Scenario: Line items have correct quantity for multiple items
    Given I have purchased two items
    And I requested an invoice
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 2 line items
    And line item number 1 should have the description "Line Item Number 1"
    And line item number 2 should have the description "Line Item Number 2"

  Scenario: Line items should not have an account code
    Given I have made a purchase
    And I requested an invoice
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And that line item should not have account code set

  Scenario: Line item should have description
    Given I have made a purchase
    And I requested an invoice
    And I have not already been invoiced
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And the line item description should include "Line Item Number 0"

  Scenario: Invoices show paypal payment method as fully paid
    We can't actually add the payment into Xero, that
    needs to be matched up from PayPal. Instead, we add a zero-value
    line item saying that it's been paid.

    Given I have made a purchase
    And I have not already been invoiced
    And I paid with Paypal
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 2 line items
    And that invoice should have a total of 1.20
    And that invoice should show that payment has been received
    And that invoice should show that the payment was made with Paypal

  Scenario: Invoices show credit card payment method as paid
    We can't actually add the payment into Xero, that
    needs to be matched up from Stripe. Instead, we add a zero-value
    line item saying that it's been paid.

    Given I have made a purchase
    And I have not already been invoiced
    And I paid with a credit card
    And my payment reference is "cus_12345"
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 2 line items
    And that invoice should have a total of 1.20
    And that invoice should show that payment has been received
    And that invoice should show that the payment was made with a credit card
    And that invoice should include the payment reference "cus_12345"

  Scenario: Invoices show direct debit payment method as paid
    We can't actually add the payment into Xero, that
    needs to be matched up from Gocardless. Instead, we add a zero-value
    line item saying that it's been paid.

    Given I have made a purchase
    And I have not already been invoiced
    And I paid by direct debit
    And my payment reference is "cus_12345"
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 2 line items
    And that invoice should have a total of 1.20
    And that invoice should show that payment has been received
    And that invoice should show that the payment was made by direct debit
    And that invoice should include the payment reference "cus_12345"

  Scenario: Invoices show invoice payment method as unpaid
    Given I have made a purchase
    And I have not already been invoiced
    And I requested an invoice
    And my payment reference is "cus_12345"
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line items
    And that invoice should have a total of 1.20
    And that invoice should show that payment has not been received
    And the invoice does not contain does not show paid with

  Scenario: Invoices to be paid later show as unpaid
    Given I have made a purchase
    And I have not already been invoiced
    And I requested an invoice
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    And that invoice should contain 1 line item
    And that invoice should have a total of 1.20
    And that invoice should show that payment has not been received

  Scenario: Deleted invoices should not be re-raised
    Given I have made a purchase
    And I have not already been invoiced
    And I requested an invoice
    When the invoicer runs
    Then an invoice should be raised in Xero against "Existing Company Inc."
    When that invoice is deleted
    When the invoicer runs
    Then an invoice should not be raised in Xero against "Existing Company Inc."

