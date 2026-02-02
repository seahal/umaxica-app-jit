# == Schema Information
#
# Table name: app_preference_timezones
# Database name: preference
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :bigint           not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_app_preference_timezones_on_option_id      (option_id)
#  index_app_preference_timezones_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_app_preference_timezones_on_option_id  (option_id => app_preference_timezone_options.id)
#  fk_rails_...                              (preference_id => app_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceTimezoneTest < ActiveSupport::TestCase
  setup do
    @preference = AppPreference.create!
  end

  test "belongs to preference" do
    timezone = AppPreferenceTimezone.new
    assert_not timezone.valid?
    assert_includes timezone.errors[:preference], "を入力してください"
  end

  test "can be created with preference and option" do
    option = app_preference_timezone_options(:asia_tokyo)
    timezone = AppPreferenceTimezone.create!(preference: @preference, option: option)
    assert_not_nil timezone.id
    assert_equal @preference, timezone.preference
    assert_equal option, timezone.option
  end

  test "sets default option_id on create" do
    timezone = AppPreferenceTimezone.create!(preference: @preference)
    assert_equal "Asia/Tokyo", timezone.option_id
  end

  test "validates uniqueness of preference" do
    option = app_preference_timezone_options(:asia_tokyo)
    AppPreferenceTimezone.create!(preference: @preference, option: option)
    duplicate_timezone = AppPreferenceTimezone.new(preference: @preference, option: option)
    assert_not duplicate_timezone.valid?
    assert_includes duplicate_timezone.errors[:preference_id], "はすでに存在します"
  end

  test "permits IANA timezone string as option_id and associates with valid option" do
    timezone = AppPreferenceTimezone.create!(preference: @preference, option_id: "Asia/Tokyo")
    assert_equal "Asia/Tokyo", timezone.option_id
    # "Asia/Tokyo" exists in fixtures and matches relaxed regex
    assert_equal app_preference_timezone_options(:asia_tokyo), timezone.option
  end

  test "AppPreferenceTimezoneOption accepts IANA format with relaxed regex" do
    option = AppPreferenceTimezoneOption.new(id: "Mars/Phobos")
    assert_predicate option, :valid?, option.errors.full_messages.to_sentence
  end

  test "AppPreferenceTimezoneOption rejects invalid characters" do
    option = AppPreferenceTimezoneOption.new(id: "BadVal$ue")
    assert_not option.valid?
    assert_includes option.errors[:id], "は不正な値です"
  end
end
