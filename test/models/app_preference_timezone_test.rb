# == Schema Information
#
# Table name: app_preference_timezones
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_app_preference_timezones_on_option_id      (option_id)
#  index_app_preference_timezones_on_preference_id  (preference_id)
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

  test "can be created with preference" do
    timezone = AppPreferenceTimezone.create!(preference: @preference)
    assert_not_nil timezone.id
    assert_equal @preference, timezone.preference
  end

  test "can be created with option" do
    option = AppPreferenceTimezoneOption.create!(id: "TEST_App_Timezone")
    timezone = AppPreferenceTimezone.create!(preference: @preference, option: option)
    assert_equal option, timezone.option
  end

  test "can be created without option" do
    timezone = AppPreferenceTimezone.create!(preference: @preference)
    assert_nil timezone.option
  end

  test "validates uniqueness of preference" do
    AppPreferenceTimezone.create!(preference: @preference)
    duplicate_timezone = AppPreferenceTimezone.new(preference: @preference)
    assert_not duplicate_timezone.valid?
    assert_includes duplicate_timezone.errors[:preference_id], "はすでに存在します"
  end
end
