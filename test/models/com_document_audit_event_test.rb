# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComDocumentAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = ComDocumentAuditEvent
    @valid_id = ComDocumentAuditEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = ComDocumentAuditEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
