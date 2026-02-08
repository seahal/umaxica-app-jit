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
end
