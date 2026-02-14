# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgDocumentBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgDocumentBehaviorEvent
    @valid_id = OrgDocumentBehaviorEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = OrgDocumentBehaviorEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
