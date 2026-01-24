# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class AppDocumentAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = AppDocumentAuditEvent
    @valid_id = "UPLOADED".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = AppDocumentAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "upcases id before validation" do
    record = AppDocumentAuditEvent.new(id: "lower_case")
    record.valid?
    assert_equal "LOWER_CASE", record.id
  end

  test "handles nil id gracefully" do
    record = AppDocumentAuditEvent.new(id: nil)
    record.valid?
    assert_nil record.id
    assert_predicate record.errors[:id], :any?
  end
end
