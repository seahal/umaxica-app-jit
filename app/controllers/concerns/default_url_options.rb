# frozen_string_literal: true

module DefaultUrlOptions
  extend ActiveSupport::Concern
  include PreferenceConstants
  include PreferenceCookie

  def default_url_options
    # TODO: Declare only raise as an interface here, and in the included destination
    # keep default_url_options_regional and default_url_options_global as private,
    # and call them at the import destination.
    options = read_cookie_preferences_for_url

    # Fallback to defaults if cookie values are not present
    options[:lx] ||= "ja"
    options[:ri] ||= "jp"
    options[:tz] ||= "jst"
    options[:ct] ||= "sy"

    super.merge(options)
  end

  private

  def default_url_options_regional
    # TODO: implement!
  end

  def default_url_options_global
    # TODO: implement!
  end

  # Todo: Include only specified values contained in query parameters here. If there are no specified parameters, do not include parameters.
  # Todo: If GLOBAL_MODE exists, only ri is required.
  def read_cookie_preferences_for_url
    parsed = read_preference_cookie
    return {} if parsed.blank?

    # Extract preference values from cookie
    {
      lx: parsed["lx"],
      ri: parsed["ri"],
      tz: parsed["tz"],
      ct: parsed["ct"],
    }.compact
  end
end
