@vcr @capsulecrm
Feature: Synchronize data update in CapsuleCRM
  In order to keep the member directory up to date
  As a commercial team member
  I want my changes in CapsuleCRM to be reflected in the members directory

  Background:
    Given there is an existing person in CapsuleCRM called "Arnold Rimmer" with email "rimmer@jmc.com"
    And that person has a tag called "Membership"

  @timecop
  Scenario: Queue updated CapsuleCRM contacts for directory sync
    Given that it's 2015-06-10 14:05
    Then that person should be queued for sync
    When the capsule monitor runs

  @timecop
  Scenario: Don't queue non-updated CapsuleCRM contacts for directory sync
    Given that it's 3 hours into the future
    Then that person should not be queued for sync
    When the capsule monitor runs
