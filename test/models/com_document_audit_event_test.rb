# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_events
# Database name: audit
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class ComDocumentAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = ComDocumentAuditEvent
    @valid_id = "UPLOADED".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = ComDocumentAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end

  test "upcases id before validation" do
    record = ComDocumentAuditEvent.new(id: "lower_case")
    record.valid?
    assert_equal "LOWER_CASE", record.id
  end
end
