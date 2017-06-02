# GOV.UK Schemas

Gem to work with the [govuk-content-schemas](https://github.com/alphagov/govuk-content-schemas).

## Installation

In your Gemfile:

```ruby
gem "govuk_schemas", "~> VERSION"
```

## Limitations

- The gem doesn't support `patternProperties` yet. On GOV.UK we [use this in the expanded frontend links](https://github.com/alphagov/govuk-content-schemas/blob/bdd97d18c7a9318e66f332f0748a410fddab1141/formats/frontend_links_definition.json#L67-L71).
- It's complicated to generate random data for `oneOf` properties. According to the JSON Schema spec a `oneOf` schema is only valid if the data is valid against *only one* of the clauses. To do this properly, we'd have to make sure that the data generated below doesn't validate against the other schemas properties.

## Usage

[Read the documentation!](https://alphagov.github.io/govuk_schemas/frames.html)

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

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.md).
