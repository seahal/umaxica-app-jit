# frozen_string_literal: true

# == Schema Information
#
# Table name: universal_user_identifiers
#
#  id              :binary           not null, primary key
#  last_otp_at     :datetime         not null
#  otp_private_key :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

class UniversalUserIdentifierTest < ActiveSupport::TestCase
  test "should create universal user identifier with valid attributes" do
    identifier = UniversalUserIdentifier.new(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "test_private_key_#{SecureRandom.hex(16)}"
    )

    assert identifier.valid?
    assert identifier.save
    assert_not_nil identifier.id
  end

  test "should allow nil otp_private_key" do
    identifier = UniversalUserIdentifier.new(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: nil
    )

    assert identifier.valid?
  end

  test "should set timestamps on create" do
    identifier = UniversalUserIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "test_private_key_#{SecureRandom.hex(16)}"
    )

    assert_not_nil identifier.created_at
    assert_not_nil identifier.updated_at
  end

  test "should update last_otp_at" do
    identifier = UniversalUserIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: 1.hour.ago,
      otp_private_key: "test_private_key_#{SecureRandom.hex(16)}"
    )

    new_time = Time.current
    identifier.update!(last_otp_at: new_time)

    assert_equal new_time.to_i, identifier.last_otp_at.to_i
  end

  test "should inherit from UniversalRecord" do
    assert_equal UniversalRecord, UniversalUserIdentifier.superclass
  end

  test "should generate binary id" do
    identifier = UniversalUserIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: "test_private_key_#{SecureRandom.hex(16)}"
    )

    assert identifier.id.is_a?(String)
    assert identifier.id.present?
  end

  test "should store and retrieve otp_private_key" do
    private_key = "secure_private_key_#{SecureRandom.hex(32)}"
    identifier = UniversalUserIdentifier.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      otp_private_key: private_key
    )

    identifier.reload
    assert_equal private_key, identifier.otp_private_key
  end
end
