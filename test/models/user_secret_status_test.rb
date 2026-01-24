# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secret_statuses
# Database name: principal
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_user_identity_secret_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
require "test_helper"

class UserSecretStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserSecretStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
    assert status.save
    assert_equal "TEST_STATUS", status.id
  end

  test "upcases id" do
    status = UserSecretStatus.new(id: "lower")
    status.valid?
    assert_equal "LOWER", status.id
  end

  test "validates length of id" do
    record = UserSecretStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
