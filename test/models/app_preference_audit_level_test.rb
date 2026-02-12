# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class AppPreferenceAuditLevelTest < ActiveSupport::TestCase
  fixtures :app_preference_audit_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = AppPreferenceAuditLevel.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end

  test "INFO constant is defined" do
    assert_equal 1, AppPreferenceAuditLevel::INFO
  end

  test "record_timestamps is disabled" do
    assert_not AppPreferenceAuditLevel.record_timestamps
  end

  test "has_many association with app_preference_audits" do
    association = AppPreferenceAuditLevel.reflect_on_association(:app_preference_audits)
    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "DEFAULTS includes INFO" do
    assert_includes AppPreferenceAuditLevel::DEFAULTS, AppPreferenceAuditLevel::INFO
  end

  test "ensure_defaults! creates the INFO record" do
    AppPreferenceAudit.delete_all
    AppPreferenceAuditLevel.where(id: AppPreferenceAuditLevel::INFO).delete_all
    assert_nil AppPreferenceAuditLevel.find_by(id: AppPreferenceAuditLevel::INFO)

    AppPreferenceAuditLevel.ensure_defaults!
    assert_not_nil AppPreferenceAuditLevel.find_by(id: AppPreferenceAuditLevel::INFO)
  end

  test "ensure_defaults! is idempotent" do
    AppPreferenceAuditLevel.ensure_defaults!
    assert_nothing_raised { AppPreferenceAuditLevel.ensure_defaults! }
  end
end
