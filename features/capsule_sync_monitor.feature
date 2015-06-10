@vcr @capsulecrm
Feature: Synchronize data update in CapsuleCRM
  In order to keep the member directory up to date
  As a commercial team member
  I want my changes in CapsuleCRM to be reflected in the members directory

  Background:
    Given there is an existing organisation in CapsuleCRM called "Omni Consumer Products"
    And that organisation has a data tag called "Membership"
    And that organisation has a data tag called "DirectoryEntry"

  @timecop
  Scenario: Queue updated CapsuleCRM contacts for directory sync
    Given that it's 1 hours into the future
    Then that organisation should be queued for sync
    When the capsule monitor runs

  @timecop
  Scenario: Don't queue non-updated CapsuleCRM contacts for directory sync
    Given that it's 3 hours into the future
    Then that organisation should not be queued for sync
    When the capsule monitor runs
