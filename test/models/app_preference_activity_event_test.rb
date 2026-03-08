# typed: false
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

  test "includes all default ids" do
    ids = AppPreferenceActivityEvent.pluck(:id)

    assert_empty(AppPreferenceActivityEvent::DEFAULTS - ids)
  end
end
