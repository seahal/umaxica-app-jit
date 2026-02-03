# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_events
# Database name: audit
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AppDocumentAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = AppDocumentAuditEvent
    @valid_id = AppDocumentAuditEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = AppDocumentAuditEvent.new(id: 2)
    assert_predicate record, :valid?
  end

  test "allows nil id on new records" do
    record = AppDocumentAuditEvent.new(id: nil)
    assert_predicate record, :valid?
  end
end
