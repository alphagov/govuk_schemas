module GovukSchemas
  class Validator
    attr_reader :schema, :item, :errors

    def initialize(schema, item)
      @schema, @item = schema, item
      validate
    end

    def valid?
      @errors.empty?
    end

  private

    def validate
      @errors ||= JSON::Validator.fully_validate(schema, item)
    end
  end
end
