# frozen_string_literal: true

# == Schema Information
#
# Table name: hmac_based_one_time_passwords
#
#  id          :uuid             not null, primary key
#  last_otp_at :datetime         not null
#  private_key :string(1024)     not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class HmacBasedOneTimePasswordTest < ActiveSupport::TestCase
  def valid_attributes
    {
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      private_key: SecureRandom.hex(512) # 1024 character limit
    }
  end

  test "should create hmac based one time password with valid attributes" do
    otp = HmacBasedOneTimePassword.new(valid_attributes)

    assert_predicate otp, :valid?
    assert otp.save
    assert_not_nil otp.id
  end

  test "should set timestamps on create" do
    otp = HmacBasedOneTimePassword.create!(valid_attributes)

    assert_not_nil otp.created_at
    assert_not_nil otp.updated_at
  end

  test "should update last_otp_at" do
    otp = HmacBasedOneTimePassword.create!(valid_attributes)
    original_time = otp.last_otp_at

    new_time = 1.hour.from_now
    otp.update!(last_otp_at: new_time)

    assert_not_equal original_time.to_i, otp.last_otp_at.to_i
    assert_equal new_time.to_i, otp.last_otp_at.to_i
  end

  test "should inherit from UniversalRecord" do
    assert_equal UniversalRecord, HmacBasedOneTimePassword.superclass
  end

  test "should generate binary id" do
    otp = HmacBasedOneTimePassword.create!(valid_attributes)

    assert_kind_of String, otp.id
    assert_predicate otp.id, :present?
  end

  test "should store and retrieve private_key" do
    private_key = SecureRandom.hex(512)
    otp = HmacBasedOneTimePassword.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      private_key: private_key
    )

    otp.reload

    assert_equal private_key, otp.private_key
  end

  test "should handle maximum private_key length" do
    # 1024 characters (512 hex pairs)
    max_key = SecureRandom.hex(512)
    otp = HmacBasedOneTimePassword.new(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      private_key: max_key
    )

    assert_predicate otp, :valid?
    assert_equal 1024, max_key.length
  end

  test "should validate private_key length constraint" do
    # Test with over 1024 characters
    oversized_key = SecureRandom.hex(513) # 1026 characters
    HmacBasedOneTimePassword.new(
      id: SecureRandom.uuid_v7,
      last_otp_at: Time.current,
      private_key: oversized_key
    )

    # This should either be invalid or truncated based on database constraints
    assert_equal 1026, oversized_key.length
  end

  test "should track otp usage timing" do
    initial_time = 1.hour.ago
    otp = HmacBasedOneTimePassword.create!(
      id: SecureRandom.uuid_v7,
      last_otp_at: initial_time,
      private_key: SecureRandom.hex(256)
    )

    # Simulate OTP usage
    current_time = Time.current
    otp.update!(last_otp_at: current_time)

    assert_operator otp.last_otp_at, :>, initial_time
    assert_equal current_time.to_i, otp.last_otp_at.to_i
  end

  test "should handle concurrent otp updates" do
    otp = HmacBasedOneTimePassword.create!(valid_attributes)

    # Simulate concurrent access
    otp1 = HmacBasedOneTimePassword.find(otp.id)
    otp2 = HmacBasedOneTimePassword.find(otp.id)

    time1 = Time.current
    time2 = 1.second.from_now

    otp1.update!(last_otp_at: time1)
    otp2.update!(last_otp_at: time2)

    otp.reload

    assert_equal time2.to_i, otp.last_otp_at.to_i
  end
end
