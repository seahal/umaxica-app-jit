# typed: false
# == Schema Information
#
# Table name: settings_preference_cookies
# Database name: setting
#
#  id              :bigint           not null, primary key
#  consent_version :uuid
#  consented       :boolean          default(FALSE), not null
#  consented_at    :datetime
#  functional      :boolean          default(FALSE), not null
#  performant      :boolean          default(FALSE), not null
#  targetable      :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  preference_id   :bigint           not null
#
# Indexes
#
#  index_settings_preference_cookies_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_settings_preference_cookies_on_preference_id  (preference_id => settings_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class SettingPreferenceCookieTest < ActiveSupport::TestCase
  setup do
    SettingPreferenceStatus.ensure_defaults!
    SettingPreferenceBindingMethod.ensure_defaults!
    SettingPreferenceDbscStatus.ensure_defaults!
    @preference = SettingPreference.create!(owner_type: "User", owner_id: 1)
  end

  test "inherits from SettingRecord" do
    assert_operator SettingPreferenceCookie, :<, SettingRecord
  end

  %i(targetable performant functional).each do |flag|
    test "validates #{flag} inclusion" do
      cookie = SettingPreferenceCookie.new(preference: @preference)
      cookie.assign_attributes(flag => nil)

      assert_not cookie.valid?
      assert_includes cookie.errors[flag], "は一覧にありません"
    end
  end

  test "validates consented inclusion" do
    cookie = SettingPreferenceCookie.new(preference: @preference)
    cookie.assign_attributes(consented: nil)

    assert_not cookie.valid?
    assert_includes cookie.errors[:consented], "は一覧にありません"
  end

  test "persists every boolean flag combination" do
    [false, true].repeated_permutation(4).each do |targetable, performant, functional, consented|
      cookie = SettingPreferenceCookie.new(
        preference: @preference,
        targetable: targetable,
        performant: performant,
        functional: functional,
        consented: consented,
      )

      assert cookie.save,
             "combo failed: targetable=#{targetable} " \
             "performant=#{performant} functional=#{functional} consented=#{consented}"
      cookie.destroy!
    end
  end

  test "belongs to preference" do
    cookie = SettingPreferenceCookie.new(targetable: true)

    assert_not cookie.valid?
    assert_not_empty cookie.errors[:preference]
  end

  test "has false as default for all flags" do
    cookie = SettingPreferenceCookie.create!(preference: @preference)

    assert_not cookie.targetable
    assert_not cookie.performant
    assert_not cookie.functional
    assert_not cookie.consented
  end

  test "validates uniqueness of preference_id" do
    SettingPreferenceCookie.create!(preference: @preference)
    duplicate = SettingPreferenceCookie.new(preference: @preference)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:preference_id]
  end
end
