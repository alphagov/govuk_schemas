require "govuk_schemas/random"

module GovukSchemas
  # TODO: @private
  class RandomItemGenerator
    def initialize(schema:)
      @schema = schema
    end

    def payload
      generate_value(@schema)
    end

  private

    def generate_value(props)
      # FIXME: nested_headers cause an infinite loop because it will recursively
      # look up the definition. Hardcode some value we know is valid.
      if props['$ref'] == '#/definitions/nested_headers'
        return [{ "text" => "hello", "level" => 1, "id" => "Nothing" }]
      end

      # Inline the defintions for references.
      if props['$ref']
        props.merge!(lookup_json_pointer(props['$ref']))
      end

      # Default to string type.
      type = props['type'] || "string"

      # TODO: this should be done in schema
      if props['properties']
        type = "object"
      end

      type = Array(type).sample

      if props['anyOf']
        generate_value(props['anyOf'].sample)
      elsif props['oneOf']
        generate_value(props['oneOf'].sample)
      elsif props['allOf']
        props['allOf'].reduce({}) do |hash, subschema|
          val = generate_value(subschema)
          hash = hash.merge(val)
          hash
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
        # TODO: subschema['minProperties'] is needed otherwise it could not satisfy the schema.
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

    def lookup_json_pointer(ref)
      elements = ref.split('/')
      elements.shift
      @schema.dig(*elements)
    end
  end
end
