# == Schema Information
#
# Table name: org_preferences
# Database name: preference
#
#  id           :bigint           not null, primary key
#  expires_at   :datetime
#  jti          :string
#  token_digest :binary
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  public_id    :string           not null
#  status_id    :bigint           default(0), not null
#
# Indexes
#
#  index_org_preferences_on_jti        (jti) UNIQUE
#  index_org_preferences_on_public_id  (public_id) UNIQUE
#  index_org_preferences_on_status_id  (status_id)
#
# Foreign Keys
#
#  fk_org_preferences_on_status_id  (status_id => org_preference_statuses.id)
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceTest < ActiveSupport::TestCase
  test "generates public_id on create" do
    preference = OrgPreference.create!
    assert_not_nil preference.public_id
    assert_equal 21, preference.public_id.length
  end

  test "validates public_id maximum length" do
    preference = OrgPreference.new(public_id: "a" * 22)
    assert_not preference.valid?
    assert_includes preference.errors[:public_id], "は21文字以内で入力してください"
  end

  test "does not overwrite existing public_id" do
    custom_id = "custom_public_id_123"
    preference = OrgPreference.create!(public_id: custom_id)
    assert_equal custom_id, preference.public_id
  end

  test "has one org_preference_cookie" do
    preference = OrgPreference.create!
    cookie = preference.create_org_preference_cookie!
    assert_equal cookie, preference.org_preference_cookie
  end

  test "destroys org_preference_cookie when destroyed" do
    preference = OrgPreference.create!
    cookie = preference.create_org_preference_cookie!
    cookie_id = cookie.id
    preference.destroy!
    assert_nil OrgPreferenceCookie.find_by(id: cookie_id)
  end

  test "has one org_preference_region" do
    preference = OrgPreference.create!
    region = preference.create_org_preference_region!
    assert_equal region, preference.org_preference_region
  end

  test "destroys org_preference_region when destroyed" do
    preference = OrgPreference.create!
    region = preference.create_org_preference_region!
    region_id = region.id
    preference.destroy!
    assert_nil OrgPreferenceRegion.find_by(id: region_id)
  end

  test "has one org_preference_timezone" do
    preference = OrgPreference.create!
    timezone = preference.create_org_preference_timezone!
    assert_equal timezone, preference.org_preference_timezone
  end

  test "destroys org_preference_timezone when destroyed" do
    preference = OrgPreference.create!
    timezone = preference.create_org_preference_timezone!
    timezone_id = timezone.id
    preference.destroy!
    assert_nil OrgPreferenceTimezone.find_by(id: timezone_id)
  end

  test "has one org_preference_language" do
    preference = OrgPreference.create!
    language = preference.create_org_preference_language!
    assert_equal language, preference.org_preference_language
  end

  test "destroys org_preference_language when destroyed" do
    preference = OrgPreference.create!
    language = preference.create_org_preference_language!
    language_id = language.id
    preference.destroy!
    assert_nil OrgPreferenceLanguage.find_by(id: language_id)
  end

  test "has one org_preference_colortheme" do
    preference = OrgPreference.create!
    colortheme = preference.create_org_preference_colortheme!
    assert_equal colortheme, preference.org_preference_colortheme
  end

  test "destroys org_preference_colortheme when destroyed" do
    preference = OrgPreference.create!
    colortheme = preference.create_org_preference_colortheme!
    colortheme_id = colortheme.id
    preference.destroy!
    assert_nil OrgPreferenceColortheme.find_by(id: colortheme_id)
  end
end
