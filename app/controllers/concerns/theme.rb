# frozen_string_literal: true

require "json"

module Theme
  extend ActiveSupport::Concern
  include PreferenceConstants

  ALLOWED_THEMES = %w[system dark light].freeze
  DEFAULT_THEME = "system"
  THEME_CODES = {
    "system" => "sy",
    "dark" => "dr",
    "light" => "li"
  }.freeze
  CODE_TO_THEME = THEME_CODES.invert.merge(
    "dk" => "dark",
    "lt" => "light"
  ).freeze
  THEME_QUERY_KEYS = %w[lx ri tz].freeze
  PREFERENCE_COOKIE_SCOPES = %w[app com].freeze

  included do
    before_action :assign_current_theme, only: :edit
  end

  def edit
    @theme_query_params = theme_redirect_params
  end

  def update
    resolved_theme = normalize_theme(params[:theme])

    if resolved_theme.nil?
      flash.now[:alert] = I18n.t("preferences.themes.invalid", scope: [ :peak, preference_scope ])
      assign_current_theme
      @theme_query_params = theme_redirect_params
      render :edit, status: :unprocessable_content
    else
      persist_theme!(resolved_theme)
      flash[:notice] = I18n.t(
        "preferences.themes.updated",
        scope: [ :peak, preference_scope ],
        theme: I18n.t(resolved_theme, scope: :themes)
      )
      redirect_to theme_redirect_url
    end
  end

  private

  def assign_current_theme
    @theme = current_theme
  end

  def current_theme
    normalize_theme(session[:theme]) ||
      normalize_theme(cookies.signed[theme_cookie_key]) ||
      DEFAULT_THEME
  end

  def normalize_theme(candidate)
    value = candidate
    value = value.to_unsafe_h if value.respond_to?(:to_unsafe_h)
    value = value.values.first if value.is_a?(Hash)
    value = value.first if value.is_a?(Array)

    normalized = value.to_s.downcase
    return CODE_TO_THEME[normalized] if CODE_TO_THEME.key?(normalized)
    return normalized if ALLOWED_THEMES.include?(normalized)

    nil
  end

  def persist_theme!(theme)
    session[:theme] = theme
    assign_current_theme

    cookies.permanent.signed[theme_cookie_key] = {
      value: theme,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }

    persist_preferences_cookie!(theme) if preference_cookie_enabled?
  end

  def preference_scope
    @preference_scope ||= controller_path.split("/")[1]
  end

  def theme_cookie_key
    :"root_#{preference_scope}_theme"
  end

  def theme_redirect_url
    # NOTE: Root domain theme functionality has been moved to Hono
    # But top/app and top/org domains still use Rails-based theme management
    query = theme_redirect_params

    case preference_scope
    when "app"
      Rails.application.routes.url_helpers.edit_peak_app_preference_theme_url(**query)
    when "org"
      Rails.application.routes.url_helpers.edit_peak_org_preference_theme_url(**query)
    when "com"
      Rails.application.routes.url_helpers.edit_peak_com_preference_theme_url(**query)
    end
  end

  # Extracts theme-related query parameters (lx, ri, tz) for redirect URLs
  # Handles various parameter formats that Rails might receive from forms/URLs
  # Returns a hash with extracted values, filtering out empty ones
  def theme_redirect_params
    THEME_QUERY_KEYS.each_with_object({}) do |key, memo|
      raw = params[key]
      next if raw.blank?

      value = extract_theme_param_value(raw)
      memo[key] = value if value.present?
    end
  end

  # Safely extracts a scalar value from various parameter types.
  # Rails may receive parameters as ActionController::Parameters, Hash, Array,
  # or scalar values depending on how they're submitted. This method handles all cases
  # by extracting the first non-blank value from nested structures.
  def extract_theme_param_value(raw)
    candidate =
      case raw
      when ActionController::Parameters
        # ActionController::Parameters acts like a hash, extract first value
        raw.to_unsafe_h.values.first
      when Hash
        # For hash params, extract the first value
        raw.values.first
      when Array
        # For array params, extract first non-blank value
        raw.compact_blank.first
      else
        # Use scalar value as-is
        raw
      end

    # Convert to string and return only if present (not empty/whitespace)
    candidate.to_s.presence
  end

  def symbolize_keys(hash)
    hash.transform_keys { |key| key.respond_to?(:to_sym) ? key.to_sym : key }
  end

  def persist_preferences_cookie!(theme)
    keys = PREFERENCE_KEYS
    defaults = DEFAULT_PREFERENCES
    cookie_key = preferences_cookie_key

    resolved = defaults.dup

    raw_preferences = cookies.signed[cookie_key]
    if raw_preferences.present?
      begin
        parsed = JSON.parse(raw_preferences)
        if parsed.is_a?(Hash)
          parsed.slice(*keys).each do |key, value|
            normalized = value.to_s.downcase
            resolved[key] = normalized.presence || defaults[key]
          end
        end
      rescue JSON::ParserError, TypeError
        # ignore malformed cookie
      end
    end

    resolved["ct"] = THEME_CODES.fetch(theme, theme)

    cookies.permanent.signed[cookie_key] = {
      value: resolved.to_json,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax
    }
  end

  def preference_cookie_enabled?
    PREFERENCE_COOKIE_SCOPES.include?(preference_scope)
  end

  def preferences_cookie_key
    :"root_#{preference_scope}_preferences"
  end
end
