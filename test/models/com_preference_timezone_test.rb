# == Schema Information
#
# Table name: com_preference_timezones
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string
#
# Indexes
#
#  index_com_preference_timezones_on_option_id      (option_id)
#  index_com_preference_timezones_on_preference_id  (preference_id) UNIQUE
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

  test "can be created with preference and option" do
    option = com_preference_timezone_options(:asia_tokyo)
    timezone = ComPreferenceTimezone.create!(preference: @preference, option: option)
    assert_not_nil timezone.id
    assert_equal @preference, timezone.preference
    assert_equal option, timezone.option
  end

  test "sets default option_id on create" do
    timezone = ComPreferenceTimezone.create!(preference: @preference)
    assert_equal "Asia/Tokyo", timezone.option_id
  end
end
