# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_timeline_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgTimelineBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgTimelineBehaviorEvent
    @valid_id = OrgTimelineBehaviorEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = OrgTimelineBehaviorEvent.new(id: 2)

    assert_predicate record, :valid?
  end
end
