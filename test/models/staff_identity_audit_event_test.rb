# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_audit_events
#
#  id :string(255)      default("NEYO"), not null, primary key
#

require "test_helper"

class StaffIdentityAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = StaffIdentityAuditEvent
    @valid_id = "LOGIN".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
