# == Schema Information
#
# Table name: com_document_audit_events
#
#  id :string(255)      default("NONE"), not null, primary key
#

require "test_helper"

class ComDocumentAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = ComDocumentAuditEvent
    @valid_id = "UPLOADED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
