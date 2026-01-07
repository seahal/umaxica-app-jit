# == Schema Information
#
# Table name: com_preference_timezones
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :uuid
#
# Indexes
#
#  index_com_preference_timezones_on_option_id      (option_id)
#  index_com_preference_timezones_on_preference_id  (preference_id)
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceTimezoneTest < ActiveSupport::TestCase
  setup do
    @preference = ComPreference.create!
  end

  test "belongs to preference" do
    timezone = ComPreferenceTimezone.new
    assert_not timezone.valid?
    assert_includes timezone.errors[:preference], "を入力してください"
  end

  test "can be created with preference" do
    timezone = ComPreferenceTimezone.create!(preference: @preference)
    assert_not_nil timezone.id
    assert_equal @preference, timezone.preference
  end

  test "can be created with option" do
    option = ComPreferenceTimezoneOption.create!
    timezone = ComPreferenceTimezone.create!(preference: @preference, option: option)
    assert_equal option, timezone.option
  end

  test "can be created without option" do
    timezone = ComPreferenceTimezone.create!(preference: @preference)
    assert_nil timezone.option
  end
end
