# == Schema Information
#
# Table name: user_recovery_codes
#
#  id                   :uuid             not null, primary key
#  expires_in           :date
#  recovery_code_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_user_recovery_codes_on_user_id  (user_id)
#
require "test_helper"

class UserRecoveryCodeTest < ActiveSupport::TestCase
  def setup
    @user_recovery_code = UserRecoveryCode.new(
      user_id: 1,
      recovery_code: "test_recovery_code_123",
      expires_in: Date.current + 30.days,
      confirm_create_recovery_code: true
    )
  end

  test "should be valid with valid attributes" do
    assert_predicate @user_recovery_code, :valid?
  end

  test "confirm_create_recovery_code should be accepted on create" do
    @user_recovery_code.confirm_create_recovery_code = false

    assert_not @user_recovery_code.valid?

    @user_recovery_code.confirm_create_recovery_code = true

    assert_predicate @user_recovery_code, :valid?
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

    assert_predicate @user_recovery_code, :valid?
  end

  test "should not set digest when recovery_code is nil" do
    no_code = UserRecoveryCode.new(
      user_id: 1,
      expires_in: Date.current + 7.days,
      confirm_create_recovery_code: true
    )

    assert_predicate no_code, :valid?
    no_code.save!

    assert_nil no_code.recovery_code_digest
  end

  test "digest does not change when saving without new recovery_code" do
    @user_recovery_code.save!
    original_digest = @user_recovery_code.recovery_code_digest
    @user_recovery_code.update!(expires_in: Date.current + 90.days)

    assert_equal original_digest, @user_recovery_code.reload.recovery_code_digest
  end

  test "digest updates when recovery_code changes on update" do
    @user_recovery_code.save!
    @user_recovery_code.recovery_code = "updated_code_456"
    @user_recovery_code.save!

    assert_equal Digest::SHA256.hexdigest("updated_code_456"), @user_recovery_code.reload.recovery_code_digest
  end

  test "recovery_code is virtual (not persisted)" do
    @user_recovery_code.save!
    found = UserRecoveryCode.find(@user_recovery_code.id)

    assert_respond_to found, :recovery_code
    assert_nil found.recovery_code
  end

  test "inherits from IdentifiersRecord" do
    assert_includes UserRecoveryCode.ancestors, IdentifiersRecord
  end

  test "whitespace recovery_code is treated as present" do
    code = UserRecoveryCode.new(
      user_id: 1,
      recovery_code: "  ",
      expires_in: Date.current + 1.day,
      confirm_create_recovery_code: true
    )

    assert code.save!
  end
end
