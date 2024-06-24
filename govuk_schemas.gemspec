lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "govuk_schemas/version"

Gem::Specification.new do |spec|
  spec.name          = "govuk_schemas"
  spec.version       = GovukSchemas::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "Gem to generate test data based on GOV.UK content schemas"
  spec.description   = "Gem to generate test data based on GOV.UK content schemas"
  spec.homepage      = "https://github.com/alphagov/govuk_schemas_gem"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "faker", "~> 3.4.1"
  # This should be kept in sync with the json-schema version of publishing-api.
  spec.add_dependency "json-schema", ">= 2.8", "< 4.4"

  spec.add_development_dependency "climate_control"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rubocop-govuk", "4.18.0"

  spec.required_ruby_version = ">= 3.1.4"
end
