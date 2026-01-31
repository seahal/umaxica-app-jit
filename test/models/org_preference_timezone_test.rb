# == Schema Information
#
# Table name: org_preference_timezones
# Database name: preference
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :integer
#  preference_id :uuid             not null
#
# Indexes
#
#  index_org_preference_timezones_on_option_id      (option_id)
#  index_org_preference_timezones_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (option_id => org_preference_timezone_options.id)
#  fk_rails_...  (preference_id => org_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceTimezoneTest < ActiveSupport::TestCase
  setup do
    @preference = OrgPreference.create!
  end

  test "belongs to preference" do
    timezone = OrgPreferenceTimezone.new
    assert_not timezone.valid?
    assert_includes timezone.errors[:preference], "を入力してください"
  end

  test "can be created with preference and option" do
    option = org_preference_timezone_options(:asia_tokyo)
    timezone = OrgPreferenceTimezone.create!(preference: @preference, option: option)
    assert_not_nil timezone.id
    assert_equal @preference, timezone.preference
    assert_equal option, timezone.option
  end

  test "sets default option_id on create" do
    timezone = OrgPreferenceTimezone.create!(preference: @preference)
    assert_equal "Asia/Tokyo", timezone.option_id
  end
end
