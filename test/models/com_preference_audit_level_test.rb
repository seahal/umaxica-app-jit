# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ComPreferenceAuditLevelTest < ActiveSupport::TestCase
  fixtures :com_preference_audit_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = ComPreferenceAuditLevel.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end

  test "has_many association with com_preference_audits" do
    association = ComPreferenceAuditLevel.reflect_on_association(:com_preference_audits)
    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "INFO constant is defined" do
    assert_equal 1, ComPreferenceAuditLevel::INFO
  end

  test "record_timestamps is disabled" do
    assert_not ComPreferenceAuditLevel.record_timestamps
  end

  test "DEFAULTS includes INFO" do
    assert_includes ComPreferenceAuditLevel::DEFAULTS, ComPreferenceAuditLevel::INFO
  end

  test "ensure_defaults! creates the INFO record" do
    ComPreferenceAudit.delete_all
    ComPreferenceAuditLevel.where(id: ComPreferenceAuditLevel::INFO).delete_all
    assert_nil ComPreferenceAuditLevel.find_by(id: ComPreferenceAuditLevel::INFO)

    ComPreferenceAuditLevel.ensure_defaults!
    assert_not_nil ComPreferenceAuditLevel.find_by(id: ComPreferenceAuditLevel::INFO)
  end

  test "ensure_defaults! is idempotent" do
    ComPreferenceAuditLevel.ensure_defaults!
    assert_nothing_raised { ComPreferenceAuditLevel.ensure_defaults! }
  end
end
