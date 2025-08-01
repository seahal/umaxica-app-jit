# frozen_string_literal: true

# == Schema Information
#
# Table name: universal_staff_identifiers
#
#  id              :binary           not null, primary key
#  last_otp_at     :datetime         not null
#  otp_private_key :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

class UniversalStaffIdentifierTest < ActiveSupport::TestCase
  test "should create universal staff identifier with valid attributes" do
    identifier = UniversalStaffIdentifier.new(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "staff_private_key_#{SecureRandom.hex(16)}"
    )

    assert identifier.valid?
    assert identifier.save
    assert_not_nil identifier.id
  end

  test "should allow nil otp_private_key" do
    identifier = UniversalStaffIdentifier.new(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: nil
    )

    assert identifier.valid?
  end

  test "should set timestamps on create" do
    identifier = UniversalStaffIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "staff_private_key_#{SecureRandom.hex(16)}"
    )

    assert_not_nil identifier.created_at
    assert_not_nil identifier.updated_at
  end

  test "should update last_otp_at for staff" do
    identifier = UniversalStaffIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: 2.hours.ago,
      otp_private_key: "staff_private_key_#{SecureRandom.hex(16)}"
    )

    new_time = Time.current
    identifier.update!(last_otp_at: new_time)

    assert_equal new_time.to_i, identifier.last_otp_at.to_i
  end

  test "should inherit from UniversalRecord" do
    assert_equal UniversalRecord, UniversalStaffIdentifier.superclass
  end

  test "should generate binary id for staff" do
    identifier = UniversalStaffIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "staff_private_key_#{SecureRandom.hex(16)}"
    )

    assert identifier.id.is_a?(String)
    assert identifier.id.present?
  end

  test "should store and retrieve staff otp_private_key" do
    private_key = "secure_staff_key_#{SecureRandom.hex(32)}"
    identifier = UniversalStaffIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: private_key
    )

    identifier.reload
    assert_equal private_key, identifier.otp_private_key
  end

  test "should be different from user identifier" do
    user_identifier = UniversalUserIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "user_key"
    )

    staff_identifier = UniversalStaffIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "staff_key"
    )

    assert_not_equal user_identifier.class, staff_identifier.class
    assert_not_equal user_identifier.id, staff_identifier.id
  end
end
