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
end
