# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: operator_messages
# Database name: message
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  public_id        :string           default(""), not null
#  staff_message_id :bigint
#
# Indexes
#
#  index_operator_messages_on_public_id         (public_id) UNIQUE
#  index_operator_messages_on_staff_message_id  (staff_message_id)
#
# Foreign Keys
#
#  fk_admin_messages_on_staff_message_id_cascade  (staff_message_id => staff_messages.id) ON DELETE => cascade
#
require "test_helper"

class OperatorMessageTest < ActiveSupport::TestCase
  fixtures :staffs

  test "is valid with a staff message" do
    record = OperatorMessage.new(staff_message: build_staff_message)

    assert_predicate record, :valid?
  end

  test "generates public_id on create" do
    record = OperatorMessage.new(staff_message: build_staff_message)

    assert_public_id_generated(record)
  end

  test "allows missing staff_message because association is optional" do
    record = OperatorMessage.new

    assert_predicate record, :valid?
  end

  private

  def build_staff_message
    StaffMessage.create!(staff: staffs(:one))
  end
end
