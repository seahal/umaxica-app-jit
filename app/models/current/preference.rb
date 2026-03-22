# typed: false
# frozen_string_literal: true

module Current
  # Immutable value object representing the resolved preference state for the current request.
  #
  # Use `Current.preference` to access -- never nil, returns NULL for guests/bearer tokens.
  #
  # Examples:
  #   Current.preference.language   # => "ja"
  #   Current.preference.timezone   # => "Asia/Tokyo"
  #   Current.preference.theme      # => "sy"
  #   Current.preference.cookie.consented?  # => false
  #   Current.preference.null?      # => true (for guests)
  class Preference
    attr_reader :language, :region, :timezone, :theme

    Cookie =
      Data.define(:consented, :functional, :performant, :targetable, :consent_version, :consented_at) do
        def consented? = !!consented

        def functional? = !!functional

        def performant? = !!performant

        def targetable? = !!targetable
      end

    DEFAULTS = {
      language: "ja",
      region: "jp",
      timezone: "Asia/Tokyo",
      theme: "sy",
    }.freeze

    NULL_COOKIE = Cookie.new(
      consented: false,
      functional: false,
      performant: false,
      targetable: false,
      consent_version: nil,
      consented_at: nil,
    ).freeze

    def initialize(language: DEFAULTS[:language], region: DEFAULTS[:region],
                   timezone: DEFAULTS[:timezone], theme: DEFAULTS[:theme],
                   cookie: NULL_COOKIE, null: false)
      @language = language.freeze
      @region = region.freeze
      @timezone = timezone.freeze
      @theme = theme.freeze
      @cookie = cookie
      @null = null
      freeze
    end

    def cookie
      @cookie
    end

    def null?
      @null
    end

    def locale
      case @language
      when "ja" then :ja
      when "en" then :en
      else :"#{@language}"
      end
    end

    def time_zone
      ActiveSupport::TimeZone[@timezone] || ActiveSupport::TimeZone["Asia/Tokyo"]
    end

    def dark_mode?
      @theme == "dr"
    end

    def light_mode?
      @theme == "li"
    end

    def system_theme?
      @theme == "sy"
    end

    def to_h
      {
        language: @language,
        region: @region,
        timezone: @timezone,
        theme: @theme,
        consented: @cookie.consented?,
      }
    end

    # Null Object -- returned when no preference is loaded (guests, bearer tokens).
    # All values are safe defaults; no DB access occurs.
    NULL = new(null: true).freeze
  end
end
