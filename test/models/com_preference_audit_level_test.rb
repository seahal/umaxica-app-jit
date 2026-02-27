# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_audit_levels
# Database name: audit
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class ComPreferenceAuditLevelTest < ActiveSupport::TestCase
  fixtures :com_preference_audit_levels

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = ComPreferenceAuditLevel.ordered.pluck(:id)

    assert_equal ordered_ids.sort, ordered_ids
  end
end
