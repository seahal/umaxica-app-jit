# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_behavior_events
# Database name: behavior
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComDocumentBehaviorEventTest < ActiveSupport::TestCase
  setup do
    @model_class = ComDocumentBehaviorEvent
    @valid_id = ComDocumentBehaviorEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = ComDocumentBehaviorEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
