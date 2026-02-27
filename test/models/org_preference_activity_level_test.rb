# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_activity_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class OrgPreferenceActivityLevelTest < ActiveSupport::TestCase
  fixtures :org_preference_activity_levels

  test "ordered scope includes default ids when position is absent" do
    ordered_ids = OrgPreferenceActivityLevel.ordered.pluck(:id)

    assert_empty(OrgPreferenceActivityLevel::DEFAULTS - ordered_ids)
  end

  test "has_many association with org_preference_activities" do
    association = OrgPreferenceActivityLevel.reflect_on_association(:org_preference_activities)

    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "INFO constant is defined" do
    assert_equal 1, OrgPreferenceActivityLevel::INFO
  end

  test "record_timestamps is disabled" do
    assert_not OrgPreferenceActivityLevel.record_timestamps
  end

  test "DEFAULTS includes INFO" do
    assert_includes OrgPreferenceActivityLevel::DEFAULTS, OrgPreferenceActivityLevel::INFO
  end

  test "ensure_defaults! creates the INFO record" do
    OrgPreferenceActivity.delete_all
    OrgPreferenceActivityLevel.where(id: OrgPreferenceActivityLevel::INFO).delete_all

    assert_nil OrgPreferenceActivityLevel.find_by(id: OrgPreferenceActivityLevel::INFO)

    OrgPreferenceActivityLevel.ensure_defaults!

    assert_not_nil OrgPreferenceActivityLevel.find_by(id: OrgPreferenceActivityLevel::INFO)
  end

  test "ensure_defaults! is idempotent" do
    OrgPreferenceActivityLevel.ensure_defaults!
    assert_nothing_raised { OrgPreferenceActivityLevel.ensure_defaults! }
  end
end
