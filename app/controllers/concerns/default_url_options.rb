module DefaultUrlOptions
  extend ActiveSupport::Concern
  include PreferenceConstants

  def default_url_options
    options = read_cookie_preferences_for_url

    # Fallback to defaults if cookie values are not present
    options[:lx] ||= "ja"
    options[:ri] ||= "jp"
    options[:tz] ||= "jst"

    super.merge(options)
  end

  private

  def read_cookie_preferences_for_url
    raw = cookies.signed[PREFERENCE_COOKIE_KEY]
    return {} if raw.blank?

    parsed = JSON.parse(raw)
    return {} unless parsed.is_a?(Hash)

    # Extract preference values from cookie
    {
      lx: parsed["lx"],
      ri: parsed["ri"],
      tz: parsed["tz"]
    }.compact
  rescue JSON::ParserError, TypeError
    {}
  end
end
