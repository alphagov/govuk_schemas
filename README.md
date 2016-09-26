# GOV.UK Schemas

Gem to work with the [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas).

## Installation

In your Gemfile:

```ruby
gem "govuk_schemas", "~> VERSION"
```

## Usage

[Read the documentation!](https://alphagov.github.io/govuk_schemas_gem/frames.html)

## Running the test suite

Make sure you have `govuk-content-schemas` cloned in a sibling directory:

```
bundle exec rake
```

### Documentation

To run a Yard server locally to preview documentation, run:

    $ bundle exec yard server --reload

To rebuild the documentation, run:

    $ bundle exec rake yard

## Releasing the gem

This gem uses [gem_publisher](https://github.com/alphagov/gem_publisher). Updating the [version](lib/govuk_schemas/version.rb) will automatically release a new version to Rubygems.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.md).
