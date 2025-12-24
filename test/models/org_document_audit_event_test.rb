# == Schema Information
#
# Table name: org_document_audit_events
#
#  id :string(255)      default("NONE"), not null, primary key
#

require "test_helper"

class OrgDocumentAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = OrgDocumentAuditEvent
    @valid_id = "UPLOADED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
