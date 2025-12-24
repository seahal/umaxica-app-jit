# == Schema Information
#
# Table name: com_contact_audit_events
#
#  id :string(255)      not null, primary key
#

require "test_helper"

class ComContactAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = ComContactAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
