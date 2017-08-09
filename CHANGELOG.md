# 2.2.0

* Add RSpec test helpers
* Add `customise_and_validate` to bring the functionality to remove fields from a payload which has been generated as a random example

# 2.1.1

* Support for a new regex in GOV.UK content schemas

# 2.1.0

* Add `Schema.schema_names` to return all schema names
* Add functionality to work with examples

# 2.0.0

* Change GovukSchemas::Schema.find to take { links_schema: 'detailded_guide' }
* Add regex for lowercase-underscore strings

# 1.0.0

* Add regex for GOV.UK campaign URLs
* Improve error messages

# 0.2.0

* Add a new regex for the new application validation in the schema
* Add documentation for the gem
* Fixes a problem with an infinite loop in a certain schema
* Now tests all available schema (a problem with specialist docs has been solved)
* Drops active-support dependency, pins json-schema dependency

# 0.1.0

* First release. Allows random content generation.
