# Open Organisation Services

[![Build Status](http://jenkins.theodi.org/job/open-orgn-services-master/badge/icon)](http://jenkins.theodi.org/job/open-orgn-services-master/)
[![Dependency Status](https://gemnasium.com/theodi/open-orgn-services.png)](https://gemnasium.com/theodi/open-orgn-services)
[![Code Climate](https://codeclimate.com/github/theodi/open-orgn-services.png)](https://codeclimate.com/github/theodi/open-orgn-services)

This repository is for code for services that support the ODI's operation as an
open organisation. Our aim is to publish open data as a mechanism to help us
function more effectively, and to act as a demonstrator of both the technical
and policy challenges.

[Feature documentation](https://relishapp.com/theodi/open-orgn-services/docs)
can be found on Relish.

## Setup

Add to Gemfile:

    gem 'open-orgn-services', :git => 'https://github.com/theodi/open-orgn-services.git'

And require if necessary:

    require 'open-orgn-services'

Configuration is loaded from environment variables. See the environment section
below for the list of which variables must be set.

## Development

You can start a local console using `foreman run bundle console`. This loads
the app and environment.

## License

This code is open source under the MIT license. See the LICENSE.md file for 
full details.

## Architecture

This repository consists of a whole bunch of glue scripts which connect various
other systems. They should all have the following features:

* Implemented as [resque jobs](https://github.com/defunkt/resque#section_Jobs).
* Minimal; each job should be as small as possible, spawing other jobs rather
  than executing big bits of code.
* Idempotent; they should be able to run many times with the same arguments and
  not cause problems.
* Testable; minimal jobs are very easy to test. This is generally done with
  cucumber features.

We use [VCR](https://github.com/vcr/vcr) to mock away any HTTP requests during
tests.

## Environment

The following environment variables should be set in order to use this gem.

    COURSES_TARGET_URL

    EVENTBRITE_API_KEY
    EVENTBRITE_USER_KEY
    EVENTBRITE_ORGANIZER_ID

    RACKSPACE_USERNAME
    RACKSPACE_API_KEY
    RACKSPACE_CONTAINER

    GAPPS_FINANCE_SPOOL_COLLECTION
    GAPPS_FINANCE_TARGET_COLLECTION
    GAPPS_FINANCE_TARGET_KEY
    GAPPS_USER_EMAIL
    GAPPS_PASSWORD

    CAPSULECRM_ACCOUNT_NAME
    CAPSULECRM_API_TOKEN
    CAPSULECRM_DEFAULT_OWNER

    TRELLO_DEV_KEY
    TRELLO_MEMBER_KEY

    XERO_CONSUMER_KEY
    XERO_CONSUMER_SECRET
    XERO_PRIVATE_KEY_PATH

