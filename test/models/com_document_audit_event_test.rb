# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_audit_events
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
end
