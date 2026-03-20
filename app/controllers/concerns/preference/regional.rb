# typed: false
# frozen_string_literal: true

module Preference::Regional
  extend ActiveSupport::Concern
  include Preference::Base

  included do
    helper_method :get_language, :get_timezone, :get_region, :get_colortheme
    before_action :set_preferences_cookie
    before_action :canonicalize_regional_params
    before_action :set_locale
    before_action :set_timezone
    before_action :set_color_theme
  end

  def default_url_options
    base_options = super || {}
    return base_options unless regional_context_requested?

    options = normalized_locale_options

    # Note: ri parameter is intentionally excluded from default_url_options
    # to prevent redirect loops in canonicalize_regional_params

    base_options.merge(options)
  end

  def regional_context_requested?
    %i(lx ct tz).all? { |key| params[key].present? }
  end

  private

  def normalized_locale_options
    lx = params[:lx].presence
    tz = params[:tz].presence
    ct = params[:ct].presence

    options = {}
    options[:lx] = lx.to_s.downcase if lx.present?
    options[:tz] = tz.to_s.downcase if tz.present?
    options[:ct] = ct.to_s.downcase if ct.present?
    options
  end

  def get_colortheme
    "sy"
  end

  def get_language
    I18n.locale.to_s
  end

  def get_region
    "jp"
  end

  def get_timezone
    "ASIA/Tokyo"
  end

  def set_locale
    set_locale_from_params
    write_preference_cookie(Preference::Base::LANGUAGE_COOKIE_KEY, I18n.locale.to_s.downcase)
  end

  def set_timezone
    timezone = preference_payload_value("tz")
    if timezone.blank? && @preferences.present?
      timezone_association = "#{@preferences.class.name.underscore}_timezone"
      timezone_record = @preferences.public_send(timezone_association)
      timezone =
        timezone_record&.option&.name ||
        option_id_to_timezone(timezone_record&.option_id, preference_prefix(@preferences))
    end

    session[:timezone] = timezone if timezone.present?

    set_timezone_from_session
    timezone_value = timezone.presence || Time.zone&.name
    write_preference_cookie(Preference::Base::TIMEZONE_COOKIE_KEY, timezone_value) if timezone_value.present?
  end

  def canonicalize_regional_params
    return unless request.get? || request.head?
    return if request.query_parameters["ri"].blank?

    canonical_query = request.query_parameters.except("ri")

    # Build redirect URL without triggering default_url_options (which adds ri back)
    # Use explicit protocol/host/port to avoid open redirect vulnerability
    redirect_url =
      if canonical_query.any?
        "#{request.base_url}#{request.path}?#{canonical_query.to_query}"
      else
        "#{request.base_url}#{request.path}"
      end

    redirect_to redirect_url, status: :moved_permanently, allow_other_host: false
  end
end
