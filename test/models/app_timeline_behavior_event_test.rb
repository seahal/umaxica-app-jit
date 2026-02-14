# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppTimelineBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = AppTimelineBehaviorEvent
    @valid_id = AppTimelineBehaviorEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = AppTimelineBehaviorEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
