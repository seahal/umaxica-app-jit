# == Schema Information
#
# Table name: app_preferences
#
#  id           :uuid             not null, primary key
#  public_id    :string
#  expires_at   :datetime
#  token_digest :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceTest < ActiveSupport::TestCase
  test "generates public_id on create" do
    preference = AppPreference.create!
    assert_not_nil preference.public_id
    assert_equal 21, preference.public_id.length
  end

  test "validates public_id maximum length" do
    preference = AppPreference.new(public_id: "a" * 22)
    assert_not preference.valid?
    assert_includes preference.errors[:public_id], "は21文字以内で入力してください"
  end

  test "does not overwrite existing public_id" do
    custom_id = "custom_public_id_123"
    preference = AppPreference.create!(public_id: custom_id)
    assert_equal custom_id, preference.public_id
  end

  test "has one app_preference_cookie" do
    preference = AppPreference.create!
    cookie = preference.create_app_preference_cookie!
    assert_equal cookie, preference.app_preference_cookie
  end

  test "destroys app_preference_cookie when destroyed" do
    preference = AppPreference.create!
    cookie = preference.create_app_preference_cookie!
    cookie_id = cookie.id
    preference.destroy!
    assert_nil AppPreferenceCookie.find_by(id: cookie_id)
  end

  test "has one app_preference_region" do
    preference = AppPreference.create!
    region = preference.create_app_preference_region!
    assert_equal region, preference.app_preference_region
  end

  test "destroys app_preference_region when destroyed" do
    preference = AppPreference.create!
    region = preference.create_app_preference_region!
    region_id = region.id
    preference.destroy!
    assert_nil AppPreferenceRegion.find_by(id: region_id)
  end

  test "has one app_preference_timezone" do
    preference = AppPreference.create!
    timezone = preference.create_app_preference_timezone!
    assert_equal timezone, preference.app_preference_timezone
  end

  test "destroys app_preference_timezone when destroyed" do
    preference = AppPreference.create!
    timezone = preference.create_app_preference_timezone!
    timezone_id = timezone.id
    preference.destroy!
    assert_nil AppPreferenceTimezone.find_by(id: timezone_id)
  end

  test "has one app_preference_language" do
    preference = AppPreference.create!
    language = preference.create_app_preference_language!
    assert_equal language, preference.app_preference_language
  end

  test "destroys app_preference_language when destroyed" do
    preference = AppPreference.create!
    language = preference.create_app_preference_language!
    language_id = language.id
    preference.destroy!
    assert_nil AppPreferenceLanguage.find_by(id: language_id)
  end

  test "has one app_preference_colortheme" do
    preference = AppPreference.create!
    colortheme = preference.create_app_preference_colortheme!
    assert_equal colortheme, preference.app_preference_colortheme
  end

  test "destroys app_preference_colortheme when destroyed" do
    preference = AppPreference.create!
    colortheme = preference.create_app_preference_colortheme!
    colortheme_id = colortheme.id
    preference.destroy!
    assert_nil AppPreferenceColortheme.find_by(id: colortheme_id)
  end
end
