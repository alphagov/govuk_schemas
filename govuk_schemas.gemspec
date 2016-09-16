# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'govuk_schemas/version'

Gem::Specification.new do |spec|
  spec.name          = "govuk_schemas"
  spec.version       = GovukSchemas::VERSION
  spec.authors       = ["GOV.UK Dev"]
  spec.email         = ["govuk-dev@digital.cabinet-office.gov.uk"]

  spec.summary       = "Gem to work with the GOV.UK content schemas"
  spec.description   = "Gem to work with the GOV.UK content schemas"
  spec.homepage      = "https://github.com/alphagov/govuk_schemas"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json-schema"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "pry-byebug"
end
