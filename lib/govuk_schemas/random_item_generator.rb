require "govuk_schemas/random"

module GovukSchemas
  # The RandomItemGenerator takes a JSON schema and outputs a random hash that
  # is valid against said schema.
  #
  # The "randomness" here is quote relative, it's particularly tailored to the
  # GOV.UK content schemas. For example, strings are limited to a couple of
  # hundred characters to keep the resulting items small.
  class RandomItemGenerator
    def initialize(schema:)
      @schema = schema
    end

    def payload
      generate_value(@schema)
    end

  private

    def generate_value(props)
      # JSON schemas can have "pointers". We use this to extract defintions and
      # reduce duplication. To make the schema easily parsable we inline the
      # reference here.
      if props['$ref']
        props.merge!(lookup_json_pointer(props['$ref']))
      end

      # Attributes with `enum` specified often omit the `type` from
      # their definition. It's most likely a string.
      type = props['type'] || "string"

      # Except when it has properties, because it's defintely an object then.
      if props['properties']
        type = "object"
      end

      # Make sure that we choose a type when there are more than one specified.
      type = Array(type).sample

      if props['anyOf']
        generate_value(props['anyOf'].sample)
      elsif props['oneOf']
        # FIXME: Generating valid data for a `oneOf` schema is quite interesting.
        # According to the JSON Schema spec a `oneOf` schema is only valid if
        # the data is valid against *only one* of the clauses. To do this
        # properly, we'd have to verify that the data generated below doesn't
        # validate against the other schemas in `props['oneOf']`.
        generate_value(props['oneOf'].sample)
      elsif props['allOf']
        props['allOf'].each_with_object({}) do |subschema, hash|
          val = generate_value(subschema)
          hash.merge(val)
        end
      elsif props['enum']
        props['enum'].sample
      elsif type == "null"
        nil
      elsif type == "object"
        generate_random_object(props)
      elsif type == "array"
        generate_random_array(props)
      elsif type == "boolean"
        Random.bool
      elsif type == "integer"
        min = props['minimum'] || 0
        max = props['maximum'] || 10
        rand(min..max)
      elsif type == "string"
        generate_random_string(props)
      else
        raise "Unknown attribute type: #{props}"
      end
    end

    def generate_random_object(subschema)
      document = {}

      (subschema['properties'] || {}).each do |attribute_name, attribute_properties|
        # TODO: When the schema contains `subschema['minProperties']` we always
        # populate all of the keys in the hash. This isn't quite random, but I
        # haven't found a nice way yet to ensure there's at least n elements in
        # the hash.
        if subschema['required'].to_a.include?(attribute_name) || subschema['minProperties'] || Random.bool
          document[attribute_name] = generate_value(attribute_properties)
        end
      end

      document
    end

    def generate_random_array(props)
      min = props['minItems'] || 0
      max = props['maxItems'] || 10
      num_items = rand(min..max)

      num_items.times.map do
        # sometimes arrays don't have `items` specified, not sure if this is a bug
        generate_value(props['items'] || {})
      end
    end

    def generate_random_string(props)
      if props["format"]
        Random.string_for_type(props['format'])
      elsif props["pattern"]
        Random.string_for_regex(props['pattern'])
      else
        Random.string(props['minLength'], props['maxLength'])
      end
    end

    # Look up a "pointer" like "#/definitions/title" in the schema.
    def lookup_json_pointer(ref)
      elements = ref.split('/')
      elements.shift
      @schema.dig(*elements)
    end
  end
end
