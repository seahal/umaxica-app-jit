# frozen_string_literal: true

# == Schema Information
#
# Table name: user_one_time_password_statuses
# Database name: principal
#
#  id :string           default("NEYO"), not null, primary key
#
# Indexes
#
#  index_user_identity_otp_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
require "test_helper"

class UserOneTimePasswordStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = UserOneTimePasswordStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
    assert status.save
    assert_equal "TEST_STATUS", status.id
  end

  test "upcases id" do
    status = UserOneTimePasswordStatus.new(id: "lower")
    status.valid?
    assert_equal "LOWER", status.id
  end

  test "validates length of id" do
    record = UserOneTimePasswordStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
