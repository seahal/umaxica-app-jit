# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: member_messages
# Database name: message
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  public_id       :string           default(""), not null
#  user_message_id :bigint
#
# Indexes
#
#  index_member_messages_on_public_id        (public_id) UNIQUE
#  index_member_messages_on_user_message_id  (user_message_id)
#
# Foreign Keys
#
#  fk_member_messages_on_user_message_id_cascade  (user_message_id => user_messages.id) ON DELETE => cascade
#
require "test_helper"

class MemberMessageTest < ActiveSupport::TestCase
  fixtures :users

  test "is valid with a user message" do
    record = MemberMessage.new(user_message: build_user_message)

    assert_predicate record, :valid?
  end

  test "generates public_id on create" do
    record = MemberMessage.new(user_message: build_user_message)

    assert_public_id_generated(record)
  end

  test "allows missing user_message because association is optional" do
    record = MemberMessage.new

    assert_predicate record, :valid?
  end

  private

  def build_user_message
    UserMessage.create!(user: users(:one))
  end
end
