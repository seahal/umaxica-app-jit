# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_telephones
#
#  id                                :uuid             not null, primary key
#  created_at                        :datetime         not null
#  locked_at                         :datetime         default("-infinity"), not null
#  number                            :string           default(""), not null
#  otp_attempts_count                :integer          default(0), not null
#  otp_counter                       :text             default(""), not null
#  otp_expires_at                    :datetime         default("-infinity"), not null
#  otp_private_key                   :string           default(""), not null
#  updated_at                        :datetime         not null
#  user_id                           :uuid             not null
#  user_identity_telephone_status_id :string(255)      default("UNVERIFIED"), not null
#
# Indexes
#
#  idx_on_user_identity_telephone_status_id_a15207191e  (user_identity_telephone_status_id)
#  index_user_identity_telephones_on_user_id            (user_id)
#

require "test_helper"

class UserIdentityTelephoneTest < ActiveSupport::TestCase
  setup do
    @user = users(:none_user)
    @valid_attributes = {
      number: "+1234567890",
      confirm_policy: true,
      confirm_using_mfa: true,
      user: @user,
    }.freeze
  end

  # Basic model structure tests
  test "should inherit from IdentitiesRecord" do
    assert_operator UserIdentityTelephone, :<, IdentitiesRecord
  end

  test "should include Telephone concern" do
    assert_includes UserIdentityTelephone.included_modules, Telephone
  end

  test "should include SetId concern" do
    assert_includes UserIdentityTelephone.included_modules, SetId
  end

  test "should include Turnstile concern" do
    assert_includes UserIdentityTelephone.included_modules, Turnstile
  end

  test "turnstile validation runs when required and surfaces custom message" do
    Turnstile.test_response = { "success" => false }

    user_telephone = UserIdentityTelephone.new(@valid_attributes)
    user_telephone.require_turnstile(
      response: "test-token",
      remote_ip: "127.0.0.1",
      error_message: "Turnstile failed",
    )

    assert_not user_telephone.valid?
    assert_includes user_telephone.errors[:base], "Turnstile failed"
  ensure
    Turnstile.test_response = nil
  end

  # Telephone concern validation tests
  test "should be valid with valid phone number and policy confirmations" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes)

    assert_predicate user_telephone, :valid?
  end

  test "should require valid phone number format" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes.merge(number: "invalid!@#"))

    I18n.with_locale(:ja) do
      assert_not user_telephone.valid?
      # Error message will be in the current locale (Japanese)
      assert_includes user_telephone.errors[:number], "は不正な値です"
    end
  end

  test "should accept phone number with country code" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes.merge(number: "+81-90-1234-5678"))

    assert_predicate user_telephone, :valid?
  end

  test "should accept phone number with parentheses" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes.merge(number: "+1 (555) 123-4567"))

    assert_predicate user_telephone, :valid?
  end

  test "should reject phone number that is too short" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes.merge(number: "12"))

    assert_not user_telephone.valid?
    assert_predicate user_telephone.errors[:number], :any?
  end

  test "should reject phone number that is too long" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes.merge(number: "+1234567890123456789012"))

    assert_not user_telephone.valid?
    assert_predicate user_telephone.errors[:number], :any?
  end

  test "should require policy confirmation" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes.merge(confirm_policy: false))

    assert_not user_telephone.valid?
    assert_predicate user_telephone.errors[:confirm_policy], :any?
  end

  test "should require MFA confirmation" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes.merge(confirm_using_mfa: false))

    assert_not user_telephone.valid?
    assert_predicate user_telephone.errors[:confirm_using_mfa], :any?
  end

  # SetId concern tests
  test "should generate UUID v7 before creation" do
    user_telephone = UserIdentityTelephone.new(@valid_attributes)

    assert_nil user_telephone.id
    user_telephone.save!

    assert_not_nil user_telephone.id
    # UUID v7 format: xxxxxxxx-xxxx-7xxx-xxxx-xxxxxxxxxxxx
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i, user_telephone.id)
  end

  test "enforces maximum telephones per user" do
    user = users(:one)
    UserIdentityTelephone::MAX_TELEPHONES_PER_USER.times do |i|
      UserIdentityTelephone.create!(
        number: "+1234567890#{i}",
        confirm_policy: true,
        confirm_using_mfa: true,
        user: user,
      )
    end

    extra_telephone = UserIdentityTelephone.new(
      number: "+19876543210",
      confirm_policy: true,
      confirm_using_mfa: true,
      user: user,
    )

    assert_not extra_telephone.valid?
    assert_includes extra_telephone.errors[:base], "exceeds maximum telephones per user (#{UserIdentityTelephone::MAX_TELEPHONES_PER_USER})"
  end
end
