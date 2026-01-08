# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_events
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class UserAuditEventTest < ActiveSupport::TestCase
  setup do
    @model_class = UserAuditEvent
    @valid_id = "LOGIN".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = UserAuditEvent.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
