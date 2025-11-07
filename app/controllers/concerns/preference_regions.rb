# frozen_string_literal: true

require "json"

# Shared behavior for the region preference controllers that live under the
# Top namespace. This keeps the three domain-specific controllers focused on
# routing concerns while centralizing preference parsing and persistence.
module PreferenceRegions
  extend ActiveSupport::Concern

  include PreferenceConstants

  Result = Struct.new(:updated, :error_key) do
    def updated?
      !!updated
    end

    def error?
      error_key.present?
    end
  end

  SELECTABLE_LANGUAGES = %w[JA EN].freeze
  DEFAULT_LANGUAGE = "JA"
  SELECTABLE_REGIONS = %w[US JP].freeze
  DEFAULT_REGION = "US"
  SELECTABLE_TIMEZONES = %w[Etc/UTC Asia/Tokyo].freeze
  DEFAULT_TIMEZONE = "Asia/Tokyo"

  LANGUAGE_COOKIE_MAP = {
    "JA" => "ja",
    "EN" => "en"
  }.freeze
  LANGUAGE_PARAM_MAP = LANGUAGE_COOKIE_MAP.invert.transform_keys(&:downcase).freeze

  REGION_COOKIE_MAP = {
    "JP" => "jp",
    "US" => "us"
  }.freeze
  REGION_PARAM_MAP = REGION_COOKIE_MAP.invert.transform_keys(&:downcase).freeze

  TIMEZONE_COOKIE_MAP = {
    "Asia/Tokyo" => "jst",
    "Etc/UTC" => "utc"
  }.freeze
  TIMEZONE_PARAM_MAP = {
    "jst" => "Asia/Tokyo",
    "utc" => "Etc/UTC",
    "kst" => "Asia/Seoul"
  }.freeze

  THEME_PARAM_MAP = {
    "dr" => "dark",
    "dk" => "dark",
    "dark" => "dark",
    "sy" => "system",
    "system" => "system",
    "li" => "light",
    "lt" => "light",
    "light" => "light"
  }.freeze

  THEME_COOKIE_MAP = {
    "dark" => "dr",
    "system" => "sy",
    "light" => "li"
  }.freeze

  def edit
    set_edit_variables
  end

  def update
    result = apply_updates(preference_params)

    if result.error?
      flash[:alert] = I18n.t(result.error_key)
      set_edit_variables
      render :edit, status: :unprocessable_content
    else
      persist_preference_cookie!
      flash[:notice] = t("messages.region_settings_updated_successfully") if result.updated?
      redirect_to preference_region_edit_url
    end
  end

  private

  def preference_params
    params.permit(:region, :country, :language, :timezone)
  end

  def apply_updates(preferences)
    updated = false

    updated ||= assign_if_present(:region, preferences[:region])
    updated ||= assign_if_present(:country, preferences[:country])

    if preferences[:language].present?
      language_result = update_language(preferences[:language])
      return language_result if language_result.error?
      updated ||= language_result.updated?
    end

    if preferences[:timezone].present?
      timezone_result = update_timezone(preferences[:timezone])
      return timezone_result if timezone_result.error?
      updated ||= timezone_result.updated?
    end

    Result.new(updated, nil)
  end

  def assign_if_present(key, value)
    return false if value.blank?

    session[key] = value
    true
  end

  def update_language(language)
    normalized = normalized_language(language)
    return error_result(:languages, :unsupported) unless normalized

    session[:language] = normalized
    Result.new(true, nil)
  end

  def normalized_language(value)
    normalized = LANGUAGE_PARAM_MAP[value.to_s.downcase] || value&.to_s&.upcase
    return unless normalized.present? && SELECTABLE_LANGUAGES.include?(normalized)

    normalized
  end

  def update_timezone(timezone)
    candidate = timezone.to_s
    return error_result(:timezones, :invalid) unless selectable_timezone?(candidate)

    zone = resolve_timezone(candidate)
    return error_result(:timezones, :invalid) unless zone

    session[:timezone] = zone_identifier(zone, candidate)
    Result.new(true, nil)
  end

  def selectable_timezone?(candidate)
    SELECTABLE_TIMEZONES.any? { |identifier| identifier.casecmp?(candidate) }
  end

  def resolve_timezone(value)
    return if value.blank?
    return value if value.is_a?(ActiveSupport::TimeZone)

    candidate = value.to_s
    ActiveSupport::TimeZone[candidate] || ActiveSupport::TimeZone.all.find do |zone|
      timezone_matches?(zone, candidate)
    end
  end

  def timezone_matches?(zone, candidate)
    [ zone.tzinfo&.identifier, zone.name, zone.to_s ].compact.any? do |option|
      option.casecmp?(candidate)
    end
  end

  def zone_identifier(zone, fallback)
    zone.tzinfo&.identifier || zone.name || fallback.to_s
  end

  def set_edit_variables
    region_param = normalize_region_from_param(params[:ri].presence)
    language_param = normalize_language_from_param(params[:lx].presence)
    timezone_param = normalize_timezone_from_param(params[:tz].presence)
    theme_param = normalize_theme_from_param(params[:ct].presence)

    @current_region = region_param || session[:region] || DEFAULT_REGION
    @current_country = session[:country] || DEFAULT_REGION
    @current_language = language_param || session[:language] || DEFAULT_LANGUAGE
    @current_theme = theme_param || session[:theme]

    timezone_candidate = timezone_param || session[:timezone]
    timezone = resolve_timezone(timezone_candidate) || resolve_timezone(DEFAULT_TIMEZONE)
    @current_timezone = timezone ? timezone.to_s : DEFAULT_TIMEZONE
  end

  def persist_preference_cookie!
    cookies.permanent.signed[PREFERENCE_COOKIE_KEY] = {
      value: cookie_preferences.to_json,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

  def cookie_preferences
    {
      "lx" => normalize_language_for_cookie,
      "ri" => normalize_region_for_cookie,
      "tz" => normalize_timezone_for_cookie,
      "ct" => normalize_theme_for_cookie
    }.compact.presence || DEFAULT_PREFERENCES
  end

  def normalize_language_for_cookie
    LANGUAGE_COOKIE_MAP.fetch(session[:language].to_s.upcase) do
      existing_cookie_preferences["lx"] || DEFAULT_PREFERENCES["lx"]
    end
  end

  def normalize_region_for_cookie
    REGION_COOKIE_MAP.fetch(session[:region].to_s.upcase) do
      existing_cookie_preferences["ri"] || DEFAULT_PREFERENCES["ri"]
    end
  end

  def normalize_timezone_for_cookie
    candidate = (session[:timezone].presence || DEFAULT_TIMEZONE).to_s
    TIMEZONE_COOKIE_MAP.each do |full, shortcode|
      return shortcode if full.casecmp?(candidate)
    end

    existing_cookie_preferences["tz"] || DEFAULT_PREFERENCES["tz"]
  end

  def normalize_theme_for_cookie
    candidate = session[:theme].presence || existing_cookie_preferences["ct"]
    THEME_COOKIE_MAP.fetch(candidate.to_s.downcase) do
      existing_cookie_preferences["ct"] || DEFAULT_PREFERENCES["ct"]
    end
  end

  def existing_cookie_preferences
    return @existing_cookie_preferences if defined?(@existing_cookie_preferences)

    raw = cookies.signed[PREFERENCE_COOKIE_KEY]
    @existing_cookie_preferences =
      begin
        parsed = JSON.parse(raw)
        parsed.is_a?(Hash) ? parsed : {}
      rescue JSON::ParserError, TypeError => error
        Rails.logger.warn("[PreferenceRegions] Failed to parse preference cookie: #{error.message}")
        {}
      end
  end

  def normalize_region_from_param(value)
    return if value.blank?

    REGION_PARAM_MAP[value.to_s.downcase] || value.to_s.upcase
  end

  def normalize_language_from_param(value)
    return if value.blank?

    LANGUAGE_PARAM_MAP[value.to_s.downcase] || value.to_s.upcase
  end

  def normalize_timezone_from_param(value)
    return if value.blank?

    TIMEZONE_PARAM_MAP[value.to_s.downcase] || value.to_s
  end

  def normalize_theme_from_param(value)
    return if value.blank?

    THEME_PARAM_MAP[value.to_s.downcase] || value.to_s
  end

  def error_result(*key_parts)
    Result.new(false, i18n_key(*key_parts))
  end

  def i18n_key(*segments)
    ([ translation_scope ] + segments).join(".")
  end

  def translation_scope
    raise NotImplementedError, "#{self.class.name} must implement #translation_scope"
  end

  def preference_region_edit_url
    raise NotImplementedError, "#{self.class.name} must implement #preference_region_edit_url"
  end
end
