require "govuk_schemas/random_content_generator"

module GovukSchemas
  # The RandomSchemaGenerator takes a JSON schema and outputs a random hash that
  # is valid against said schema.
  #
  # The "randomness" here is quote relative, it's particularly tailored to the
  # GOV.UK content schemas. For example, strings are limited to a couple of
  # hundred characters to keep the resulting items small.
  #
  # @private
  class RandomSchemaGenerator
    def initialize(schema:, seed: nil)
      @schema = schema
      @random = Random.new(seed || Random.new_seed)
      @generator = RandomContentGenerator.new(random: @random)
    end

    def payload
      generate_value(@schema)
    end

  private

    def generate_value(props)
      # TODO: #/definitions/nested_headers are recursively nested and can cause
      # infinite loops. We need to add something that detects and prevents the
      # loop. In the meantime return a valid value.
      if props["$ref"] == "#/definitions/nested_headers"
        return [{ "text" => "1", "level" => 1, "id" => "ABC" }]
      end

      # JSON schemas can have "pointers". We use this to extract defintions and
      # reduce duplication. To make the schema easily parsable we inline the
      # reference here.
      if props["$ref"]
        props.merge!(lookup_json_pointer(props["$ref"]))
      end

      # Attributes with `enum` specified often omit the `type` from
      # their definition. It's most likely a string.
      type = props["type"] || "string"

      # Except when it has properties, because it's defintely an object then.
      if props["properties"]
        type = "object"
      end

      # Make sure that we choose a type when there are more than one specified.
      type = Array(type).sample(random: @random)

      if props["anyOf"]
        generate_value(props["anyOf"].sample(random: @random))
      elsif props["oneOf"] && type != "object"
        # FIXME: Generating valid data for a `oneOf` schema is quite interesting.
        # According to the JSON Schema spec a `oneOf` schema is only valid if
        # the data is valid against *only one* of the clauses. To do this
        # properly, we'd have to verify that the data generated below doesn't
        # validate against the other schemas in `props['oneOf']`.
        generate_value(props["oneOf"].sample(random: @random))
      elsif props["allOf"]
        props["allOf"].each_with_object({}) do |subschema, hash|
          val = generate_value(subschema)
          hash.merge(val)
        end
      elsif props["enum"]
        props["enum"].sample(random: @random)
      elsif type == "null"
        nil
      elsif type == "object"
        generate_random_object(props)
      elsif type == "array"
        generate_random_array(props)
      elsif type == "boolean"
        @generator.bool
      elsif type == "integer"
        min = props["minimum"] || 0
        max = props["maximum"] || 10
        @random.rand(min..max)
      elsif type == "string"
        generate_random_string(props)
      else
        raise "Unknown attribute type: #{props}"
      end
    end

    def generate_random_object(subschema)
      document = {}

      one_of_sample = subschema.fetch("oneOf", []).sample(random: @random) || {}

      (subschema["properties"] || {}).each do |attribute_name, attribute_properties|
        # TODO: When the schema contains `subschema['minProperties']` we always
        # populate all of the keys in the hash. This isn't quite random, but I
        # haven't found a nice way yet to ensure there's at least n elements in
        # the hash.
        should_generate_value = @generator.bool \
          || subschema["required"].to_a.include?(attribute_name) \
          || (one_of_sample["required"] || {}).to_a.include?(attribute_name) \
          || (one_of_sample["properties"] || {}).keys.include?(attribute_name) \
          || subschema["minProperties"] \

        next unless should_generate_value

        one_of_properties = (one_of_sample["properties"] || {})[attribute_name]
        document[attribute_name] = if one_of_properties
                                     generate_value(one_of_properties)
                                   else
                                     generate_value(attribute_properties)
                                   end
      end

      document
    end

    def generate_random_array(props)
      min = props["minItems"] || 0
      max = props["maxItems"] || 10
      unique = props["uniqueItems"] == true
      num_items = @random.rand(min..max)
      items = []
      attempts = 0
      max_attempts = num_items * 100

      until items.length == num_items
        # sometimes arrays don't have `items` specified, not sure if this is a bug
        new_value = generate_value(props["items"] || {})

        if unique && items.include?(new_value)
          attempts += 1
          raise "Failed to create a unique array item after #{max_attempts} attempts" if attempts >= max_attempts
          next
        end

        attempts = 0
        items << new_value
      end

      items
    end

    def generate_random_string(props)
      if props["format"]
        @generator.string_for_type(props["format"])
      elsif props["pattern"]
        @generator.string_for_regex(props["pattern"])
      else
        @generator.string(props["minLength"], props["maxLength"])
      end
    end

    # Look up a "pointer" like "#/definitions/title" in the schema.
    def lookup_json_pointer(ref)
      elements = ref.split("/")
      elements.shift
      @schema.dig(*elements) || raise("Definition `#{ref}` not found in the schema")
    end
  end
end
