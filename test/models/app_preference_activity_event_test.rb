# == Schema Information
#
# Table name: app_preference_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

require "test_helper"

class AppPreferenceActivityEventTest < ActiveSupport::TestCase
  fixtures :app_preference_activity_events

  test "accepts integer ids" do
    record = AppPreferenceActivityEvent.new(id: 9)
    assert_predicate record, :valid?
  end

  test "ordered scope sorts by id when position is absent" do
    ordered_ids = AppPreferenceActivityEvent.ordered.pluck(:id)
    assert_equal ordered_ids.sort, ordered_ids
  end
end
