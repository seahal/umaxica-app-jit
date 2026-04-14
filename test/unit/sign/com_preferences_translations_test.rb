# typed: false
# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../config/environment"

class SignComPreferencesTranslationsTest < Minitest::Test
  LOCALES = %i(en ja).freeze

  KEYS = %w(
    apex.com.preferences.title
    apex.com.preferences.description
    apex.com.preferences.email_settings
    apex.com.preferences.region_settings
    apex.com.preferences.timezone_settings
    apex.com.preferences.language_settings
    apex.com.preferences.theme_settings
    apex.com.preferences.cookie_settings
    apex.com.preferences.reset_settings
    apex.com.preferences.up_link
    apex.com.preferences.back_to_settings
    apex.com.preferences.locale_settings
    apex.com.preferences.submitting
    apex.com.preferences.update_settings
    apex.com.preferences.theme.select_theme
    apex.com.preferences.regions.title
    apex.com.preferences.regions.region_section
    apex.com.preferences.regions.select_region
    apex.com.preferences.regions.select_region_prompt
    apex.com.preferences.regions.select_region_selector.US
    apex.com.preferences.regions.select_region_selector.JP
    apex.com.preferences.regions.select_language
    apex.com.preferences.regions.select_language_prompt
    apex.com.preferences.regions.select_language_selector.JAPANESE
    apex.com.preferences.regions.select_language_selector.ENGLISH
    apex.com.preferences.regions.select_timezone
    apex.com.preferences.regions.select_timezone_prompt
    apex.com.preferences.regions.select_timezone_selector.UTC
    apex.com.preferences.regions.select_timezone_selector.JST
    apex.com.preferences.region.timezone.link
    apex.com.preferences.region.language.link
    apex.com.preference.cookie.edit.description
    apex.com.preference.cookie.edit.h1
    apex.com.preference.cookie.edit.accept_necessary_cookies
    apex.com.preference.cookie.edit.accept_functional_cookies
    apex.com.preference.cookie.edit.accept_performance_cookies
    apex.com.preference.cookie.edit.accept_targeting_cookies
    apex.com.preference.cookie.edit.accept_consent_cookies
    apex.com.preference.resets.title
    apex.com.preference.resets.description
    apex.com.preference.resets.button
    apex.com.preference.resets.confirm
    apex.com.preference.resets.back
    apex.com.preference.resets.destroyed
    apex.com.preference.theme.edit.title
    apex.com.preference.theme.edit.description
    apex.com.preference.theme.edit.options.light
    apex.com.preference.theme.edit.options.dark
    apex.com.preference.theme.edit.options.system
    apex.com.preference.language.edit.heading
    apex.com.preference.language.edit.description
    apex.com.preference.language.edit.language_label
    apex.com.preference.timezone.edit.heading
    apex.com.preference.timezone.edit.description
    apex.com.preference.timezone.edit.timezone_label
    apex.com.preference.locale.edit.title
    apex.com.preference.locale.edit.description
    apex.com.preference.locale.edit.language_options.ja
    apex.com.preference.locale.edit.language_options.en
    apex.com.preference.locale.edit.timezone_options.UTC
    apex.com.preference.locale.edit.timezone_options.JST
    apex.com.preference.locale.edit.language_section
    apex.com.preference.locale.edit.language_label
    apex.com.preference.locale.edit.language_prompt
    apex.com.preference.locale.edit.timezone_section
    apex.com.preference.locale.edit.timezone_label
    apex.com.preference.locale.edit.timezone_prompt
    apex.com.preference.locale.edit.submit
  ).freeze

  def test_required_preference_translations_exist
    LOCALES.each do |locale|
      KEYS.each do |key|
        assert I18n.exists?(key, locale), "missing #{key} for #{locale}"
      end
    end
  end
end
