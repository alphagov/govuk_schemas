# GOV.UK Schemas

Gem to work with the [schemas in publishing api](https://github.com/alphagov/publishing-api/tree/main/content_schemas).

## Installation

In your Gemfile:

```ruby
gem "govuk_schemas", "~> VERSION"
```

## Usage

[Read the documentation!](http://www.rubydoc.info/gems/govuk_schemas)

## Running the test suite

Make sure you have `publishing-api` cloned in a sibling directory:

```
bundle exec rake
```

## Development

In order to run the tests successfully you also need [publishing-api](https://github.com/alphagov/publishing-api) checked
out into the same parent directory as govuk_schemas.

The tests can then be run with `bundle exec rspec`.

## License

The gem is available as open source under the terms of the [MIT License](LICENCE).
