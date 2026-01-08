# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_audit_events
#
#  id :string(255)      default("NEYO"), not null, primary key
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
end
