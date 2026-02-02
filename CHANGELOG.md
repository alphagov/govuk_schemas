# Changelog

## 6.2.2

* Update dependencies

## 6.2.1

* Release latest updates to dependencies

## 6.2.0

* Remove Faker dependency [PR](https://github.com/alphagov/govuk_schemas/pull/172)

## 6.1.1

* Add a new regex generator for a content block order item [PR](https://github.com/alphagov/govuk_schemas/pull/170)

## 6.1.0

* Introduce a "one of everything" strategy for RandomSchemaGenerator https://github.com/alphagov/govuk_schemas/pull/168

## 6.0.0

* BREAKING: Drop support for Ruby 3.1 [PR](https://github.com/alphagov/govuk_schemas/pull/141)

## 5.0.4

* Ensure `Faker` is added as a non-development dependency

## 5.0.3

* Add support for `email` string types
* Use `Faker` gem to generate emails and URLs
* Improve error messages when an unknown type is given in `GovukSchemas::RandomContentGenerator#string_for_type`

## 5.0.2

* Fix issue where customised schema validation message was incorrect for a modified payload

## 5.0.1

* Improve speed of random schema generation for customised content items

## 5.0.0

* BREAKING: Drop support for Ruby 3.0. The minimum required Ruby version is now 3.1.4.
* Add support for Ruby 3.3.
* Add support for `json-schema` 3.3.

## 4.7.0

* Update `json-schema` dependency.

## 4.6.0

* Drop support for Ruby 2.7.
* Fix guidance on fixing a regex issue to reference correct filename.
* Add support for `^[1-9][0-9]{3}$` regex to resolve exceptions randomly generating specialist_documents.

## 4.5.0

* General support for content schemas in Publishing API:
  * Update default content schemas url to point to publishing api rather than govuk-content-schemas. This is because we are merging schemas into publishing api.
  * Update path of allowed_document_types.yml to reflect new location in publishing api, allowing us to remove a symlink.
  * Introduce a setter method for manually configuring the path to schemas, outside of an env variable

## 4.4.1

* Fix `Validator` module to handle JSON or other object types being passed as the payload ([#68](https://github.com/alphagov/govuk_schemas/pull/68))

## 4.4.0

* Adds support for applications that use Minitest by adding an `AssertMatchers` module ([#66](https://github.com/alphagov/govuk_schemas/pull/66))

## 4.3.0

* Generate unique items for arrays with the "uniqueItems" property. ([#63](https://github.com/alphagov/govuk_schemas/pull/63))

## 4.2.0

* Add support for generating random HH:MM time strings that match a regex. ([#62](https://github.com/alphagov/govuk_schemas/pull/62))

## 4.1.1

* Fix RandomSchemaGenerator.new always returning equivalent generators ([#60](https://github.com/alphagov/govuk_schemas/pull/60))

## 4.1.0

* Add `seed` parameter to `GovukSchemas::RandomExample` to make the random behaviour deterministic. Given the same seed, the same randomised outputs will be returned ([#56](https://github.com/alphagov/govuk_schemas/pull/56)).

## 4.0.1

* Bump the required Ruby version to >= 2.6.x.

## 4.0.0

* Change RSpec::Matchers, rename `be_valid_against_schema` to `be_valid_against_publisher_schema` and add `be_valid_against_frontend_schema` plus `be_valid_against_notification_schema`.

## 3.3.0

* Support generating objects with an `oneOf` property.

## 3.2.0

* Add `GovukSchemas::DocumentTypes.valid_document_types` (PR #48)

## 3.1.0

* Update json-schema dependency

## 3.0.1

* Change order of output when validation errors occur during random example generation

## 3.0.0

* Move to block based customisation of randomly generated payloads. This removes the existing methods: `customise_and_validate` and `merge_and_validate`. In addition `GovukSchemas::RandomExample.for_schema(schema)` now returns the payload hash directly.

## 2.3.0

* Allow looking up examples to work with schemas stored in `formats/{format}/{schema_type}/examples/` and `examples/{format}/{schema_type}/` to allow schema examples to move.

## 2.2.0

* Add RSpec test helpers
* Add `customise_and_validate` to bring the functionality to remove fields from a payload which has been generated as a random example

## 2.1.1

* Support for a new regex in GOV.UK content schemas

## 2.1.0

* Add `Schema.schema_names` to return all schema names
* Add functionality to work with examples

## 2.0.0

* Change GovukSchemas::Schema.find to take { links_schema: 'detailded_guide' }
* Add regex for lowercase-underscore strings

## 1.0.0

* Add regex for GOV.UK campaign URLs
* Improve error messages

## 0.2.0

* Add a new regex for the new application validation in the schema
* Add documentation for the gem
* Fixes a problem with an infinite loop in a certain schema
* Now tests all available schema (a problem with specialist docs has been solved)
* Drops active-support dependency, pins json-schema dependency

## 0.1.0

* First release. Allows random content generation.
