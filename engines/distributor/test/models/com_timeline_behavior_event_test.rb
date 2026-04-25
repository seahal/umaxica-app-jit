# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComTimelineBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = ComTimelineBehaviorEvent
    @valid_id = ComTimelineBehaviorEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = ComTimelineBehaviorEvent.new(id: 2)

    assert_predicate record, :valid?
  end
end
