require "faker"

module GovukSchemas
  # @private
  class RandomContentGenerator
    WORDS = %w[Lorem ipsum dolor sit amet consectetur adipiscing elit. Ut suscipit at mauris non bibendum. Ut ac massa est. Aenean tempor imperdiet leo vel interdum. Nam sagittis cursus sem ultricies scelerisque. Quisque porttitor risus vel risus finibus eu sollicitudin nisl aliquet. Sed sed lectus ac dolor molestie interdum. Nam molestie pellentesque purus ac vestibulum. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse non tempor eros. Mauris eu orci hendrerit volutpat lorem in tristique libero. Duis a nibh nibh.].freeze
    DOMAIN_SUFFIXES = %w[co.uk com].freeze

    def initialize(random: Random.new)
      @random = random
      Faker::Config.random = @random
    end

    def string_for_type(type)
      case type
      when "date-time"
        time
      when "uri"
        uri
      when "email"
        [username, domain_name].join("@")
      else
        raise <<~DOC
           Unsupported JSON schema type `#{type}`

           Supported formats are:
             - date-time
             - uri
             - email

           This can be fixed by adding a type to the `string_for_type` method in
          `lib/govuk_schemas/random_content_generator.rb` in https://github.com/alphagov/govuk_schemas
        DOC
      end
    end

    def time
      arbitrary_time = Time.new(2012, 2, 1)
      (arbitrary_time + @random.rand(0..500_000_000)).iso8601
    end

    # TODO: make this more random with query string, optional anchor.
    def uri
      "https://#{domain_name}/#{base_path}#{anchor}"
    end

    def base_path
      "/#{@random.rand(1..5).times.map { uuid }.join('/')}"
    end

    def govuk_subdomain_url
      host = Faker::Internet.domain_name(subdomain: true, domain: "gov.uk")
      Faker::Internet.url(host:, path: base_path)
    end

    def string(minimum_chars = nil, maximum_chars = nil)
      minimum_chars ||= 0
      maximum_chars ||= 100
      WORDS.sample(@random.rand(minimum_chars..maximum_chars), random: @random).join(" ")
    end

    def bool
      @random.rand(2) == 1
    end

    def anchor
      "##{hex}"
    end

    def random_identifier(separator:)
      WORDS.sample(@random.rand(1..10), random: @random)
        .join("-")
        .gsub(/[^a-z0-9\-_]+/i, "-")
        .gsub("-", separator)
    end

    def uuid
      # matches uuid regex e.g. e058aad7-ce86-5181-8801-4ddcb3c8f27c
      # /^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/
      "#{hex(8)}-#{hex(4)}-1#{hex(3)}-a#{hex(3)}-#{hex(12)}"
    end

    def hex(length = 10)
      length.times.map { bool ? random_letter : random_number }.join("")
    end

    def string_for_regex(pattern)
      case pattern.to_s
      when "^(placeholder|placeholder_.+)$"
        ["placeholder", "placeholder_#{WORDS.sample(random: @random)}"].sample(random: @random)
      when "^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$"
        uuid
      when "^/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?$"
        base_path
      when "^[1-9][0-9]{3}[-/](0[1-9]|1[0-2])[-/](0[1-9]|[12][0-9]|3[0-1])$"
        Date.today.iso8601
      when "^[1-9][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[0-1])$"
        Date.today.iso8601
      when "^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
        Time.now.strftime("%H:%m")
      when "^[1-9][0-9]{3}$"
        rand(1000...9999).to_s
      when "^#.+$"
        anchor
      when "[a-z-]"
        random_identifier(separator: "-")
      when "^[a-z_]+$"
        random_identifier(separator: "_")
      when "^/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?(\\?([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?(#([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?$"
        base_path
      when "^https://([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[A-Za-z0-9])?\\.)+campaign\\.gov\\.uk(/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?(\\?([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?(#([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?)?$"
        govuk_subdomain_url
      when "^https://([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[A-Za-z0-9])?\\.)*gov\\.uk(/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?(\\?([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?(#([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?)?$"
        govuk_subdomain_url
      when '[a-z0-9\-_]'
        "#{hex}-#{hex}"
      when "^addresses|contact_links|email_addresses|telephones.[a-z0-9]+(?:-[a-z0-9]+)*$"
        content_block_order_item
      else
        raise <<~DOC
          Don't know how to generate random string for pattern #{pattern.inspect}

          This probably means you've introduced a new regex in to a content
          schema in Publishing API. Because it's very hard to generate a valid
          string from a regex alone, we have to specify a method to generate
          random data for each regex in the schemas.

          This can be fixed by adding your regex to `lib/govuk_schemas/random_content_generator.rb`
          in https://github.com/alphagov/govuk_schemas
        DOC
      end
    end

  private

    def username
      WORDS.sample(random: @random).downcase
    end

    def domain_name
      [
        WORDS.sample(random: @random).downcase,
        DOMAIN_SUFFIXES.sample(random: @random)
      ].join(".")
    end

    def content_block_order_item
      [
        %w[addresses contact_links email_addresses telephones].sample,
        ".",
        Faker::Internet.slug(glue: "-"),
      ].join
    end

    def random_letter
      letters = ("a".."f").to_a
      letters[@random.rand(0..letters.count - 1)]
    end

    def random_number
      numbers = ("0".."9").to_a
      numbers[@random.rand(0..numbers.count - 1)]
    end
  end
end
