Testing
=======
This cookbook has tests in the GitHub repository. To run the tests:

    git clone git://github.com/hw-cookbooks/runit.git
    cd runit
    bundle install

There are two kinds of tests, unit tests and integration tests.

## Unit Tests

The resource/provider code is unit tested with rspec. To run these
tests, use rake:

    bundle exec rake spec

## Integration Tests

Integration tests are setup to run under minitest-chef. They are
automatically run under test kitchen.

    bundle exec kitchen test

This tests the default recipe ("default" configuration), and various
uses of the `runit_service` resource ("service" configuration).
