# be yard doc -n && be ruby doccy.rb > test.md

require 'yard'
require 'erb'

YARD::Registry.load

repo = "govuk_schemas_gem"
website_base = "https://github.com/alphagov/#{repo}/blob/master/"
all = YARD::Registry.all(:class)

template = File.read('doc_template.erb')
renderer = ERB.new(template)
content = renderer.result(binding)

puts content
