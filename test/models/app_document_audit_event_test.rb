# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_audit_events
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
end
