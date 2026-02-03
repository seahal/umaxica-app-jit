# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_levels
# Database name: audit
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
end
