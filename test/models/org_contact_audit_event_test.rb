# == Schema Information
#
# Table name: org_contact_audit_events
#
#  id :string(255)      not null, primary key
#

require "test_helper"

class OrgContactAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = OrgContactAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
