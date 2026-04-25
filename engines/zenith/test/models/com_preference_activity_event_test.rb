# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_preference_activity_events
# Database name: activity
#
#  id :bigint           not null, primary key
#
require "test_helper"

class ComPreferenceActivityEventTest < ActiveSupport::TestCase
  fixtures :com_preference_activity_events

  test "has correct NOTHING constant" do
    assert_equal 0, ComPreferenceActivityEvent::NOTHING
  end

  test "can load nothing status from db" do
    status = ComPreferenceActivityEvent.find(ComPreferenceActivityEvent::NOTHING)

    assert_equal 0, status.id
  end

  test "accepts integer ids" do
    record = ComPreferenceActivityEvent.new(id: 9)

    assert_predicate record, :valid?
  end

  test "includes all default ids" do
    ids = ComPreferenceActivityEvent.pluck(:id)

    assert_empty(ComPreferenceActivityEvent::DEFAULTS - ids)
  end
end
