# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_audit_events
# Database name: audit
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_document_audit_events_on_code  (code) UNIQUE
#

require "test_helper"

class OrgDocumentAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgDocumentAuditEvent
    @valid_id = "UPLOADED".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = OrgDocumentAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "upcases id before validation" do
    record = OrgDocumentAuditEvent.new(id: "lower_case")
    record.valid?
    assert_equal "LOWER_CASE", record.id
  end
end
