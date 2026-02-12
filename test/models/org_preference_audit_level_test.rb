# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_levels
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class OrgPreferenceAuditLevelTest < ActiveSupport::TestCase
  fixtures :org_preference_audit_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = OrgPreferenceAuditLevel.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end

  test "has_many association with org_preference_audits" do
    association = OrgPreferenceAuditLevel.reflect_on_association(:org_preference_audits)
    assert_equal :has_many, association.macro
    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "INFO constant is defined" do
    assert_equal 1, OrgPreferenceAuditLevel::INFO
  end

  test "record_timestamps is disabled" do
    assert_not OrgPreferenceAuditLevel.record_timestamps
  end

  test "DEFAULTS includes INFO" do
    assert_includes OrgPreferenceAuditLevel::DEFAULTS, OrgPreferenceAuditLevel::INFO
  end

  test "ensure_defaults! creates the INFO record" do
    OrgPreferenceAudit.delete_all
    OrgPreferenceAuditLevel.where(id: OrgPreferenceAuditLevel::INFO).delete_all
    assert_nil OrgPreferenceAuditLevel.find_by(id: OrgPreferenceAuditLevel::INFO)

    OrgPreferenceAuditLevel.ensure_defaults!
    assert_not_nil OrgPreferenceAuditLevel.find_by(id: OrgPreferenceAuditLevel::INFO)
  end

  test "ensure_defaults! is idempotent" do
    OrgPreferenceAuditLevel.ensure_defaults!
    assert_nothing_raised { OrgPreferenceAuditLevel.ensure_defaults! }
  end
end
