# == Schema Information
#
# Table name: app_document_audit_events
#
#  id                    :string(255)      default("NONE"), not null, primary key
#  app_document_audit_id :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#
# Indexes
#
#  index_app_document_audit_events_on_app_document_audit_id  (app_document_audit_id)
#

require "test_helper"

class AppDocumentAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = AppDocumentAuditEvent
    @valid_id = "UPLOADED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
