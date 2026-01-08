# == Schema Information
#
# Table name: com_preference_timezone_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceTimezoneOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = ComPreferenceTimezoneOption.create!(id: "TEST_COM_TIMEZONE")
    assert_not_nil option.id
  end

  test "has many com_preference_timezones" do
    option = ComPreferenceTimezoneOption.create!(id: "TEST_COM_TIMEZONE")
    preference = ComPreference.create!
    timezone = ComPreferenceTimezone.create!(preference: preference, option: option)
    assert_includes option.com_preference_timezones, timezone
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceTimezoneOption.create!(id: "TEST_COM_TIMEZONE")
    preference = ComPreference.create!
    ComPreferenceTimezone.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = ComPreferenceTimezoneOption.new(id: "invalid-id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = ComPreferenceTimezoneOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
