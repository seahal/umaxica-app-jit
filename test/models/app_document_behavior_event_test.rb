# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppDocumentBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = AppDocumentBehaviorEvent
    @valid_id = AppDocumentBehaviorEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = AppDocumentBehaviorEvent.new(id: 2)
    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = AppDocumentBehaviorEvent.new(id: nil)
    assert_predicate record, :valid?
  end
end
