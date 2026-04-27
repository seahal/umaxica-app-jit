# typed: false
# frozen_string_literal: true

module Preference::Localization
  extend ActiveSupport::Concern

  included do
    around_action :apply_localization_preferences
  end

  private

  def apply_localization_preferences(&)
    locale = I18n.default_locale
    tz = "UTC"

    if respond_to?(:effective_context)
      ctx = effective_context
      locale = ctx[:lx] if ctx[:lx].present?
      tz = ctx[:tz] if ctx[:tz].present?
    else
      locale = params[:lx].presence || cookies[Preference::Base::LANGUAGE_COOKIE_KEY].presence || I18n.default_locale
      tz = params[:tz].presence || cookies[Preference::Base::TIMEZONE_COOKIE_KEY].presence || "UTC"
    end

    tz =
      case tz.to_s.downcase
      when "jst" then "Asia/Tokyo"
      when "utc" then "Etc/UTC"
      else tz
      end

    Time.use_zone(tz) do
      I18n.with_locale(locale, &)
    end
  rescue I18n::InvalidLocale
    Time.use_zone("Etc/UTC") { I18n.with_locale(I18n.default_locale, &) }
  rescue ArgumentError
    Time.use_zone("Etc/UTC") { I18n.with_locale(I18n.default_locale, &) }
  end
end
