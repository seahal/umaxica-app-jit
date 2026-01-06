# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class StaffAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = StaffAuditEvent
    @valid_id = "LOGIN".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
