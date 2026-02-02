# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_statuses
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_preference_statuses_on_code  (code) UNIQUE
#
require "test_helper"

class ComPreferenceStatusTest < ActiveSupport::TestCase
  fixtures :com_preference_statuses

  test "ordered scope sorts by position then id" do
    ordered = ComPreferenceStatus.ordered.pluck(:id)
    assert_equal ["NEYO", "DELETED"], ordered
  end

  test "upcases id before validation" do
    status = ComPreferenceStatus.new(id: "custom", position: 3)
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
