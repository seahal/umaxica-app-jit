# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_statuses
# Database name: preference
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  com_preference_statuses_position_unique  (position) UNIQUE
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
