# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: audit_timestamps
# Database name: activity
#
#  id                  :uuid             not null, primary key
#  audit_record_type   :string           not null
#  error_code          :integer
#  hash_algorithm      :string           default("SHA256"), not null
#  issued_at           :datetime         not null
#  nonce               :binary
#  policy_oid          :string
#  serial_number       :string           not null
#  tsa_certificate     :binary
#  tsa_request         :binary           not null
#  tsa_response        :binary           not null
#  tsa_token           :binary           not null
#  verification_status :boolean
#  verified_at         :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  audit_record_id     :bigint           not null
#  status_id           :integer          default(0), not null
#
# Indexes
#
#  index_audit_timestamps_on_audit_record         (audit_record_type,audit_record_id) UNIQUE
#  index_audit_timestamps_on_issued_at            (issued_at)
#  index_audit_timestamps_on_record_and_status    (audit_record_type,audit_record_id,status_id)
#  index_audit_timestamps_on_serial_number        (serial_number) UNIQUE
#  index_audit_timestamps_on_status_id            (status_id)
#  index_audit_timestamps_on_verification_status  (verification_status) WHERE (verification_status IS NOT NULL)
#

require "test_helper"

class AuditTimestampTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    UserActivityEvent.ensure_defaults!
    UserActivityLevel.ensure_defaults!
    UserActivity.delete_all
    @activity = UserActivity.create!(
      actor: @user,
      actor_type: "User",
      subject_id: @user.id,
      subject_type: "User",
      event_id: UserActivityEvent::LOGGED_IN,
      level_id: UserActivityLevel::INFO,
    )
  end

  test "tsa_request presence validation" do
    timestamp = AuditTimestamp.new(
      audit_record: @activity,
      tsa_token: "token",
      tsa_request: nil,
      tsa_response: "response",
      serial_number: "SN#{SecureRandom.hex(8)}",
      issued_at: Time.current,
    )

    assert_not timestamp.valid?
    assert_not_empty timestamp.errors[:tsa_request]
  end

  test "tsa_response presence validation" do
    timestamp = AuditTimestamp.new(
      audit_record: @activity,
      tsa_token: "token",
      tsa_request: "request",
      tsa_response: nil,
      serial_number: "SN#{SecureRandom.hex(8)}",
      issued_at: Time.current,
    )

    assert_not timestamp.valid?
    assert_not_empty timestamp.errors[:tsa_response]
  end

  test "implicit_order_column is created_at" do
    assert_equal :created_at, AuditTimestamp.implicit_order_column
  end

  test "serial_number uniqueness validation" do
    existing = AuditTimestamp.create!(
      audit_record: @activity,
      tsa_token: "token1",
      tsa_request: "request1",
      tsa_response: "response1",
      serial_number: "SN_UNIQUE_TEST",
      issued_at: Time.current,
    )

    duplicate = AuditTimestamp.new(
      audit_record: @activity,
      tsa_token: "token2",
      tsa_request: "request2",
      tsa_response: "response2",
      serial_number: existing.serial_number,
      issued_at: Time.current,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:serial_number]
  end
end
