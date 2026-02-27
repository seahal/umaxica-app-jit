# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ComPreferenceActivityLevelTest < ActiveSupport::TestCase
  fixtures :com_preference_activity_levels

  test "includes all default ids" do
    ids = ComPreferenceActivityLevel.pluck(:id)

    assert_empty(ComPreferenceActivityLevel::DEFAULTS - ids)
  end

  test "has_many association with com_preference_activities" do
    association = ComPreferenceActivityLevel.reflect_on_association(:com_preference_activities)

    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "INFO constant is defined" do
    assert_equal 1, ComPreferenceActivityLevel::INFO
  end

  test "record_timestamps is disabled" do
    assert_not ComPreferenceActivityLevel.record_timestamps
  end

  test "DEFAULTS includes INFO" do
    assert_includes ComPreferenceActivityLevel::DEFAULTS, ComPreferenceActivityLevel::INFO
  end

  test "ensure_defaults! creates the INFO record" do
    ComPreferenceActivity.delete_all
    ComPreferenceActivityLevel.where(id: ComPreferenceActivityLevel::INFO).delete_all

    assert_nil ComPreferenceActivityLevel.find_by(id: ComPreferenceActivityLevel::INFO)

    ComPreferenceActivityLevel.ensure_defaults!

    assert_not_nil ComPreferenceActivityLevel.find_by(id: ComPreferenceActivityLevel::INFO)
  end

  test "ensure_defaults! is idempotent" do
    ComPreferenceActivityLevel.ensure_defaults!
    assert_nothing_raised { ComPreferenceActivityLevel.ensure_defaults! }
  end
end
