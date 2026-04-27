# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # NOTE: Abstract base controller.
  # Defines global CSRF protection and shared behavior.
  # Not intended for direct use or routing; inherit in concrete controllers.
  abstract!

  protect_from_forgery using: :header_or_legacy_token,
                       trusted_origins: ENV.fetch("TRUSTED_ORIGINS", "").split(","),
                       with: :exception

  around_action :apply_localization_preferences

  private

  def apply_localization_preferences(&)
    # The actual implementation of precedence (URL param > cookie > user pref > default)
    # is handled by Preference::Global if included, or defaults here.

    locale = params[:lx].presence || cookies[Preference::Base::LANGUAGE_COOKIE_KEY].presence || I18n.default_locale
    tz = params[:tz].presence || cookies[Preference::Base::TIMEZONE_COOKIE_KEY].presence || "UTC"

    if respond_to?(:effective_context)
      ctx = effective_context
      locale = ctx[:lx] if ctx[:lx].present?
      tz = ctx[:tz] if ctx[:tz].present?
    end

    # Robust timezone handling: map short codes to valid TZ names
    tz =
      case tz.to_s.downcase
      when "jst" then "Asia/Tokyo"
      when "utc" then "Etc/UTC"
      else tz
      end

    begin
      Time.use_zone(tz) do
        I18n.with_locale(locale, &)
      end
    rescue ArgumentError
      # Fallback to UTC if timezone is still invalid
      Time.use_zone("UTC") do
        I18n.with_locale(locale, &)
      end
    end
  end
end
