# frozen_string_literal: true

require "test_helper"

class OrgPreferenceStatusTest < ActiveSupport::TestCase
  fixtures :org_preference_statuses

  test "ordered scope sorts by position then id" do
    ordered = OrgPreferenceStatus.ordered.pluck(:id)
    assert_equal ["NEYO", "DELETED"], ordered
  end

  test "upcases id before validation" do
    status = OrgPreferenceStatus.new(id: "custom", position: 3)
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
