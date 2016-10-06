module GovukSchemas
  # @private
  module Random
    class << self
      WORDS = %w[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut suscipit at mauris non bibendum. Ut ac massa est. Aenean tempor imperdiet leo vel interdum. Nam sagittis cursus sem ultricies scelerisque. Quisque porttitor risus vel risus finibus, eu sollicitudin nisl aliquet. Sed sed lectus ac dolor molestie interdum. Nam molestie pellentesque purus ac vestibulum. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Suspendisse non tempor eros. Mauris eu orci hendrerit, volutpat lorem in, tristique libero. Duis a nibh nibh.].freeze

      def string_for_type(type)
        if type == 'date-time'
          time
        elsif type == 'uri'
          uri
        else
          raise "Unknown attribute type `#{type}`"
        end
      end

      def time
        seconds_ago = rand(10_000_000) - 5_000_000
        (Time.now + seconds_ago).iso8601
      end

      # TODO: make this more random with query string, optional anchor.
      def uri
        "http://example.com#{base_path}#{anchor}"
      end

      def base_path
        "/" + rand(1..5).times.map { SecureRandom.uuid }.join('/')
      end

      def govuk_campaign_url
        subdomain = rand(1..5).times.map { ('a'..'z').to_a.sample(rand(1..5)).join }.join('.')
        "https://#{subdomain}.campaign.gov.uk#{base_path}"
      end

      def string(minimum_chars = nil, maximum_chars = nil)
        minimum_chars = minimum_chars || 0
        maximum_chars = maximum_chars || 100
        WORDS.sample(rand(minimum_chars..maximum_chars)).join(' ')
      end

      def bool
        rand(2) == 1
      end

      def anchor
        "##{SecureRandom.hex}"
      end

      def string_for_regex(pattern)
        case pattern.to_s
        when '^(placeholder|placeholder_.+)$'
          ['placeholder', "placeholder_#{WORDS.sample}"].sample
        when '^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$'
          SecureRandom.uuid
        when "^/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?$"
          base_path
        when "^[1-9][0-9]{3}[-/](0[1-9]|1[0-2])[-/](0[1-9]|[12][0-9]|3[0-1])$"
          Date.today.iso8601
        when "^[1-9][0-9]{3}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[0-1])$"
          Date.today.iso8601
        when "^#.+$"
          anchor
        when "[a-z-]"
          Utils.parameterize(WORDS.sample(rand(1..10)).join('-'))
        when "^[a-z_]+$"
          Utils.parameterize(WORDS.sample(rand(1..10)).join(' ')).gsub('-', '_')
        when "^/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?(\\?([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?(#([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?$"
          base_path
        when "^https://([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[A-Za-z0-9])?\\.)+campaign\\.gov\\.uk(/(([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})+(/([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)*)?(\\?([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?(#([a-zA-Z0-9._~!$&'()*+,;=:@-]|%[0-9a-fA-F]{2})*)?)?$"
          govuk_campaign_url
        when '[a-z0-9\-_]'
          "#{SecureRandom.hex}-#{SecureRandom.hex}"
        else
          raise <<-doc
            Don't know how to generate random string for pattern #{pattern.inspect}

            This propably means you've introduced a new regex in  govuk-content-schemas.
            Because it's very hard to generate a valid string from a regex alone,
            we have to specify a method to generate random data for each regex in
            the schemas.

            To fix this:

            - Add your regex to `lib/govuk_schemas/random.rb`
          doc
        end
      end
    end
  end
end
