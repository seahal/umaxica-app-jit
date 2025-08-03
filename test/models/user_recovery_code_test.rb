# == Schema Information
#
# Table name: user_recovery_codes
#
#  id                   :uuid             not null, primary key
#  expires_in           :date
#  recovery_code_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint
#
# Indexes
#
#  index_user_recovery_codes_on_user_id  (user_id)
#
require "test_helper"

class UserRecoveryCodeTest < ActiveSupport::TestCase
  def setup
    @user_recovery_code = UserRecoveryCode.new(
      user_id: SecureRandom.uuid,
      recovery_code: "test_recovery_code_123",
      expires_in: Date.current + 30.days,
      confirm_create_recovery_code: true
    )
  end

  test "should be valid with valid attributes" do
    assert @user_recovery_code.valid?
  end

  test "confirm_create_recovery_code should be accepted on create" do
    @user_recovery_code.confirm_create_recovery_code = false
    assert_not @user_recovery_code.valid?

    @user_recovery_code.confirm_create_recovery_code = true
    assert @user_recovery_code.valid?
  end

  test "should set recovery_code_digest when recovery_code is provided" do
    assert_nil @user_recovery_code.recovery_code_digest
    @user_recovery_code.save!
    assert_not_nil @user_recovery_code.recovery_code_digest
    assert_equal Digest::SHA256.hexdigest("test_recovery_code_123"), @user_recovery_code.recovery_code_digest
  end

  test "should not require confirm_create_recovery_code on update" do
    @user_recovery_code.save!

    # Update without confirmation should be valid
    @user_recovery_code.expires_in = Date.current + 60.days
    @user_recovery_code.confirm_create_recovery_code = false
    assert @user_recovery_code.valid?
  end
end
