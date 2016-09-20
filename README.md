# GOV.UK Schemas

Gem to work with the [GOV.UK Content Schemas](https://github.com/alphagov/govuk-content-schemas).

## Installation

The gem is currently unreleased:

```ruby
gem "govuk_schemas", github: "alphagov/govuk_schemas"
```

## Usage

### Generating random content


Generate a valid content item for the [frontend schema for detailed guides](...).

```ruby
irb(main):001:0> GovukSchemas::RandomExample.for_frontend("detailed_guide").payload
=> {"base_path"=>"/e42dd28e9ed96dc17626ac8b1b7b8511", "title"=>"dolor est...", "publishing_app"=>"elit"...}
```

### Using it to guarantee valid data

```ruby
irb(main):001:0> random = GovukSchemas::RandomExample.for_frontend("detailed_guide")
irb(main):002:0> random.merge_and_validate(base_path: "/foo")
=> {"base_path"=>"/foo", "title"=>"dolor est...", "publishing_app"=>"elit"...}
```

Which will fail if the data you provide would generate an invalid content item.

```ruby
irb(main):001:0> random = GovukSchemas::RandomExample.for_frontend("detailed_guide")
irb(main):002:0> random.merge_and_validate(base_path: nil)
=> ERROR
```

## Running the test suite

Make sure you have `govuk-content-schemas` cloned in a sibling directory:

```
bundle exec rake
```

## Releasing the gem

This gem is currently not on Rubygems. Use it directly from GitHub.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
