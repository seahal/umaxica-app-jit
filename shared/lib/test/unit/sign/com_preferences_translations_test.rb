# typed: false
# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../config/environment"

class SignComPreferencesTranslationsTest < Minitest::Test
  LOCALES = %i(en ja).freeze

  KEYS = %w(
    acme.com.preferences.title
    acme.com.preferences.description
    acme.com.preferences.email_settings
    acme.com.preferences.region_settings
    acme.com.preferences.timezone_settings
    acme.com.preferences.language_settings
    acme.com.preferences.theme_settings
    acme.com.preferences.cookie_settings
    acme.com.preferences.reset_settings
    acme.com.preferences.up_link
    acme.com.preferences.back_to_settings
    acme.com.preferences.locale_settings
    acme.com.preferences.submitting
    acme.com.preferences.update_settings
    acme.com.preferences.theme.select_theme
    acme.com.preferences.regions.title
    acme.com.preferences.regions.region_section
    acme.com.preferences.regions.select_region
    acme.com.preferences.regions.select_region_prompt
    acme.com.preferences.regions.select_region_selector.US
    acme.com.preferences.regions.select_region_selector.JP
    acme.com.preferences.regions.select_language
    acme.com.preferences.regions.select_language_prompt
    acme.com.preferences.regions.select_language_selector.JAPANESE
    acme.com.preferences.regions.select_language_selector.ENGLISH
    acme.com.preferences.regions.select_timezone
    acme.com.preferences.regions.select_timezone_prompt
    acme.com.preferences.regions.select_timezone_selector.UTC
    acme.com.preferences.regions.select_timezone_selector.JST
    acme.com.preferences.region.timezone.link
    acme.com.preferences.region.language.link
    acme.com.preference.cookie.edit.description
    acme.com.preference.cookie.edit.h1
    acme.com.preference.cookie.edit.accept_necessary_cookies
    acme.com.preference.cookie.edit.accept_functional_cookies
    acme.com.preference.cookie.edit.accept_performance_cookies
    acme.com.preference.cookie.edit.accept_targeting_cookies
    acme.com.preference.cookie.edit.accept_consent_cookies
    acme.com.preference.resets.title
    acme.com.preference.resets.description
    acme.com.preference.resets.button
    acme.com.preference.resets.confirm
    acme.com.preference.resets.back
    acme.com.preference.resets.destroyed
    acme.com.preference.theme.edit.title
    acme.com.preference.theme.edit.description
    acme.com.preference.theme.edit.options.light
    acme.com.preference.theme.edit.options.dark
    acme.com.preference.theme.edit.options.system
    acme.com.preference.language.edit.heading
    acme.com.preference.language.edit.description
    acme.com.preference.language.edit.language_label
    acme.com.preference.timezone.edit.heading
    acme.com.preference.timezone.edit.description
    acme.com.preference.timezone.edit.timezone_label
    acme.com.preference.locale.edit.title
    acme.com.preference.locale.edit.description
    acme.com.preference.locale.edit.language_options.ja
    acme.com.preference.locale.edit.language_options.en
    acme.com.preference.locale.edit.timezone_options.UTC
    acme.com.preference.locale.edit.timezone_options.JST
    acme.com.preference.locale.edit.language_section
    acme.com.preference.locale.edit.language_label
    acme.com.preference.locale.edit.language_prompt
    acme.com.preference.locale.edit.timezone_section
    acme.com.preference.locale.edit.timezone_label
    acme.com.preference.locale.edit.timezone_prompt
    acme.com.preference.locale.edit.submit
  ).freeze

  def test_required_preference_translations_exist
    LOCALES.each do |locale|
      KEYS.each do |key|
        assert I18n.exists?(key, locale), "missing #{key} for #{locale}"
      end
    end
  end
end
