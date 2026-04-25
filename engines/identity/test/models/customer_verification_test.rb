# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_verifications
# Database name: token
#
#  id                :bigint           not null, primary key
#  expires_at        :datetime         not null
#  last_used_at      :datetime
#  revoked_at        :datetime
#  token_digest      :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  customer_token_id :bigint           not null
#
# Indexes
#
#  index_customer_verifications_on_customer_token_id  (customer_token_id)
#  index_customer_verifications_on_expires_at         (expires_at)
#  index_customer_verifications_on_token_digest       (token_digest) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_token_id => customer_tokens.id)
#

require "test_helper"

class CustomerVerificationTest < ActiveSupport::TestCase
  def setup
    CustomerTokenStatus.find_or_create_by!(id: CustomerTokenStatus::NOTHING)
    CustomerTokenKind.find_or_create_by!(id: CustomerTokenKind::BROWSER_WEB)
    CustomerTokenBindingMethod.find_or_create_by!(id: CustomerTokenBindingMethod::NOTHING)
    CustomerTokenDbscStatus.find_or_create_by!(id: CustomerTokenDbscStatus::NOTHING)

    @customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}")
    @customer_token = CustomerToken.create!(customer: @customer)
  end

  test "should be valid with required attributes" do
    verification = CustomerVerification.new(
      customer_token: @customer_token,
      token_digest: "test_digest_#{SecureRandom.hex(16)}",
      expires_at: 15.minutes.from_now,
    )

    assert_predicate verification, :valid?
  end

  test "should require token_digest" do
    verification = CustomerVerification.new(
      customer_token: @customer_token,
      expires_at: 15.minutes.from_now,
    )

    assert_not verification.valid?
    assert_not_empty verification.errors[:token_digest]
  end

  test "should require expires_at" do
    verification = CustomerVerification.new(
      customer_token: @customer_token,
      token_digest: "test_digest_#{SecureRandom.hex(16)}",
    )

    assert_not verification.valid?
    assert_not_empty verification.errors[:expires_at]
  end

  test "should require customer_token" do
    verification = CustomerVerification.new(
      token_digest: "test_digest_#{SecureRandom.hex(16)}",
      expires_at: 15.minutes.from_now,
    )

    assert_not verification.valid?
    assert_not_empty verification.errors[:customer_token]
  end

  test "token_digest must be unique" do
    digest = "unique_digest_#{SecureRandom.hex(16)}"
    CustomerVerification.create!(
      customer_token: @customer_token,
      token_digest: digest,
      expires_at: 15.minutes.from_now,
    )

    duplicate = CustomerVerification.new(
      customer_token: @customer_token,
      token_digest: digest,
      expires_at: 15.minutes.from_now,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:token_digest]
  end

  test "active? returns true when not revoked and before expiry" do
    freeze_time do
      verification = CustomerVerification.create!(
        customer_token: @customer_token,
        token_digest: "active_digest_#{SecureRandom.hex(16)}",
        expires_at: 1.minute.from_now,
      )

      assert_predicate verification, :active?
    end
  end

  test "active? returns false when revoked" do
    verification = CustomerVerification.create!(
      customer_token: @customer_token,
      token_digest: "revoked_digest_#{SecureRandom.hex(16)}",
      expires_at: 15.minutes.from_now,
      revoked_at: Time.current,
    )

    assert_not verification.active?
  end

  test "active? returns false at exact expiry" do
    freeze_time do
      expires_at = Time.current
      verification = CustomerVerification.create!(
        customer_token: @customer_token,
        token_digest: "expiry_digest_#{SecureRandom.hex(16)}",
        expires_at: expires_at,
        last_used_at: Time.current,
      )

      assert_not verification.active?
    end
  end

  test "active? returns false after expiry" do
    verification = CustomerVerification.create!(
      customer_token: @customer_token,
      token_digest: "expired_digest_#{SecureRandom.hex(16)}",
      expires_at: 1.minute.ago,
      last_used_at: 2.minutes.ago,
    )

    assert_not verification.active?
  end

  test "issue_for_token! creates verification and returns raw token" do
    verification, raw_token = CustomerVerification.issue_for_token!(token: @customer_token)

    assert_predicate verification, :persisted?
    assert_predicate raw_token, :present?
    assert_equal verification, CustomerVerification.find(verification.id)
  end

  test "issue_for_token! revokes previous active verifications" do
    first_verification, _first_raw = CustomerVerification.issue_for_token!(token: @customer_token)

    assert_predicate first_verification.reload, :active?

    second_verification, _second_raw = CustomerVerification.issue_for_token!(token: @customer_token)

    assert_not first_verification.reload.active?
    assert_predicate first_verification.reload.revoked_at, :present?
    assert_predicate second_verification.reload, :active?
  end

  test "digest_token returns consistent digest for same input" do
    raw_token = "test_token_123"
    digest1 = CustomerVerification.digest_token(raw_token)
    digest2 = CustomerVerification.digest_token(raw_token)

    assert_equal digest1, digest2
    assert_predicate digest1, :present?
  end

  test "belongs to customer_token" do
    verification = CustomerVerification.create!(
      customer_token: @customer_token,
      token_digest: "belongs_digest_#{SecureRandom.hex(16)}",
      expires_at: 15.minutes.from_now,
    )

    assert_equal @customer_token, verification.customer_token
  end

  test "TTL constant is 15 minutes" do
    assert_equal 15.minutes, CustomerVerification::TTL
  end
end
