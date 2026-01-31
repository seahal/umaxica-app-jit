# frozen_string_literal: true

# == Schema Information
#
# Table name: org_preference_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_org_preference_audit_levels_on_id  (id) UNIQUE
#
require "test_helper"

class OrgPreferenceAuditLevelTest < ActiveSupport::TestCase
  fixtures :org_preference_audit_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = OrgPreferenceAuditLevel.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
