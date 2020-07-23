module GovukSchemas
  # @private
  class RandomContentGenerator
    WORDS = %w[Lorem ipsum dolor sit amet consectetur adipiscing elit. Ut suscipit at mauris non bibendum. Ut ac massa est. Aenean tempor imperdiet leo vel interdum. Nam sagittis cursus sem ultricies scelerisque. Quisque porttitor risus vel risus finibus eu sollicitudin nisl aliquet. Sed sed lectus ac dolor molestie interdum. Nam molestie pellentesque purus ac vestibulum. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse non tempor eros. Mauris eu orci hendrerit volutpat lorem in tristique libero. Duis a nibh nibh.].freeze

    def initialize(random: Random.new)
      @random = random
    end

    def string_for_type(type)
      if type == "date-time"
        time
      elsif type == "uri"
        uri
      else
        raise "Unknown attribute type `#{type}`"
      end
    end

    def time
      seconds_ago = @random.rand(-5_000_000..4_999_999)
      (Time.now + seconds_ago).iso8601
    end

    # TODO: make this more random with query string, optional anchor.
    def uri
      "http://example.com#{base_path}#{anchor}"
    end

    def base_path
      "/" + @random.rand(1..5).times.map { uuid }.join("/")
    end

    def govuk_subdomain_url
      subdomain = @random.rand(2..4).times.map {
        ("a".."z").to_a.sample(@random.rand(3..8), random: @random).join
      }.join(".")
      "https://#{subdomain}.gov.uk#{base_path}"
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
      Utils.parameterize(WORDS.sample(@random.rand(1..10), random: @random).join("-")).gsub("-", separator)
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
      else
        raise <<-DOC
          Don't know how to generate random string for pattern #{pattern.inspect}

          This propably means you've introduced a new regex in  govuk-content-schemas.
          Because it's very hard to generate a valid string from a regex alone,
          we have to specify a method to generate random data for each regex in
          the schemas.

          To fix this:

          - Add your regex to `lib/govuk_schemas/random.rb`
        DOC
      end
    end

  private

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
