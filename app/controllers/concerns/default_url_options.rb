module DefaultUrlOptions
  extend ActiveSupport::Concern
  include PreferenceConstants

  def default_url_options
    # TODO: これは interface として、raise のみをせんげんし、読み込んだ先で
    # dfault_url_options_regional と　default_url_options_global を private でおいておいて、
    # それをインポート先で呼び出すようにする。
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

  # Todo: クエリパラメタに含まれる指定の値だけは、ここで含めるようにする。指定のパラメタが無い場合は、パラメタを含めないようにする。
  # Todo: GLPBAL_MODE があり場合は、ri のみは必須とする。
  def read_cookie_preferences_for_url
    raw = cookies.signed[PREFERENCE_COOKIE_KEY]
    return {} if raw.blank?

    parsed = JSON.parse(raw)
    return {} unless parsed.is_a?(Hash)

    # Extract preference values from cookie
    {
      lx: parsed["lx"],
      ri: parsed["ri"],
      tz: parsed["tz"],
      ct: parsed["ct"]
    }.compact
  rescue JSON::ParserError, TypeError
    {}
  end
end
