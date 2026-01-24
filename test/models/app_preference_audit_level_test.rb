# frozen_string_literal: true

require "test_helper"

class AppPreferenceAuditLevelTest < ActiveSupport::TestCase
  fixtures :app_preference_audit_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = AppPreferenceAuditLevel.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
