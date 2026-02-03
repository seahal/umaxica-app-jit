# == Schema Information
#
# Table name: com_preferences
# Database name: preference
#
#  id           :bigint           not null, primary key
#  expires_at   :datetime
#  jti          :string
#  token_digest :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  public_id    :string           not null
#  status_id    :bigint           default(2), not null
#
# Indexes
#
#  index_com_preferences_on_jti        (jti) UNIQUE
#  index_com_preferences_on_public_id  (public_id) UNIQUE
#  index_com_preferences_on_status_id  (status_id)
#
# Foreign Keys
#
#  fk_com_preferences_on_status_id  (status_id => com_preference_statuses.id)
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceTest < ActiveSupport::TestCase
  setup do
    ComPreferenceStatus.find_or_create_by!(id: ComPreferenceStatus::NEYO)
  end

  test "generates public_id on create" do
    preference = ComPreference.create!
    assert_not_nil preference.public_id
    assert_equal 21, preference.public_id.length
  end

  test "validates public_id maximum length" do
    preference = ComPreference.new(public_id: "a" * 22)
    assert_not preference.valid?
    assert_includes preference.errors[:public_id], "は21文字以内で入力してください"
  end

  test "does not overwrite existing public_id" do
    custom_id = "custom_public_id_123"
    preference = ComPreference.create!(public_id: custom_id)
    assert_equal custom_id, preference.public_id
  end

  test "has one com_preference_cookie" do
    preference = ComPreference.create!
    cookie = preference.create_com_preference_cookie!
    assert_equal cookie, preference.com_preference_cookie
  end

  test "destroys com_preference_cookie when destroyed" do
    preference = ComPreference.create!
    cookie = preference.create_com_preference_cookie!
    cookie_id = cookie.id
    preference.destroy!
    assert_nil ComPreferenceCookie.find_by(id: cookie_id)
  end

  test "has one com_preference_region" do
    preference = ComPreference.create!
    option = com_preference_region_options(:jp)
    region = preference.create_com_preference_region!(option: option)
    assert_equal region, preference.com_preference_region
  end

  test "destroys com_preference_region when destroyed" do
    preference = ComPreference.create!
    option = com_preference_region_options(:jp)
    region = preference.create_com_preference_region!(option: option)
    region_id = region.id
    preference.destroy!
    assert_nil ComPreferenceRegion.find_by(id: region_id)
  end

  test "has one com_preference_timezone" do
    preference = ComPreference.create!
    option = com_preference_timezone_options(:asia_tokyo)
    timezone = preference.create_com_preference_timezone!(option: option)
    assert_equal timezone, preference.com_preference_timezone
  end

  test "destroys com_preference_timezone when destroyed" do
    preference = ComPreference.create!
    option = com_preference_timezone_options(:asia_tokyo)
    timezone = preference.create_com_preference_timezone!(option: option)
    timezone_id = timezone.id
    preference.destroy!
    assert_nil ComPreferenceTimezone.find_by(id: timezone_id)
  end

  test "has one com_preference_language" do
    preference = ComPreference.create!
    option = com_preference_language_options(:ja)
    language = preference.create_com_preference_language!(option: option)
    assert_equal language, preference.com_preference_language
  end

  test "destroys com_preference_language when destroyed" do
    preference = ComPreference.create!
    option = com_preference_language_options(:ja)
    language = preference.create_com_preference_language!(option: option)
    language_id = language.id
    preference.destroy!
    assert_nil ComPreferenceLanguage.find_by(id: language_id)
  end

  test "has one com_preference_colortheme" do
    preference = ComPreference.create!
    option = com_preference_colortheme_options(:light)
    colortheme = preference.create_com_preference_colortheme!(option: option)
    assert_equal colortheme, preference.com_preference_colortheme
  end

  test "destroys com_preference_colortheme when destroyed" do
    preference = ComPreference.create!
    option = com_preference_colortheme_options(:light)
    colortheme = preference.create_com_preference_colortheme!(option: option)
    colortheme_id = colortheme.id
    preference.destroy!
    assert_nil ComPreferenceColortheme.find_by(id: colortheme_id)
  end
end
