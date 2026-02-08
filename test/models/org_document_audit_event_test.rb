# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_audit_events
# Database name: activity
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgDocumentAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgDocumentAuditEvent
    @valid_id = OrgDocumentAuditEvent::CREATED
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = OrgDocumentAuditEvent.new(id: 2)
    assert_predicate record, :valid?
  end
end
