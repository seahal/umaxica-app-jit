# frozen_string_literal: true

# == Schema Information
#
# Table name: user_passkey_statuses
# Database name: principal
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_user_identity_passkey_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
require "test_helper"

class UserPasskeyStatusTest < ActiveSupport::TestCase
  fixtures :user_passkey_statuses

  test "upcases id before validation" do
    status = UserPasskeyStatus.new(id: "custom")
    status.valid?
    assert_equal "CUSTOM", status.id
  end
end
