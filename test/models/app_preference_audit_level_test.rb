# frozen_string_literal: true

# == Schema Information
#
# Table name: app_preference_audit_levels
# Database name: audit
#
#  id :integer          default(0), not null, primary key
#
# Indexes
#
#  index_app_preference_audit_levels_on_id  (id) UNIQUE
#
require "test_helper"

class AppPreferenceAuditLevelTest < ActiveSupport::TestCase
  fixtures :app_preference_audit_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = AppPreferenceAuditLevel.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
