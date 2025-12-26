# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_audit_events
#
#  id         :string(255)      default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class UserIdentityAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = UserIdentityAuditEvent
    @valid_id = "LOGIN".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
