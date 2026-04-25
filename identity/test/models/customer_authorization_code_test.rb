# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_authorization_codes
# Database name: guest
#
#  id                    :bigint           not null, primary key
#  acr                   :string           default("aal1"), not null
#  auth_method           :string           default(""), not null
#  code                  :string(64)       not null
#  code_challenge        :string           not null
#  code_challenge_method :string(8)        default("S256"), not null
#  consumed_at           :datetime
#  nonce                 :string
#  redirect_uri          :text             not null
#  revoked_at            :datetime
#  scope                 :string
#  state                 :string
#  varnishable_at        :datetime         not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  client_id             :string(64)       not null
#  customer_id           :bigint           not null
#
# Indexes
#
#  index_customer_authorization_codes_on_code            (code) UNIQUE
#  index_customer_authorization_codes_on_customer_id     (customer_id)
#  index_customer_authorization_codes_on_varnishable_at  (varnishable_at)
#
require "test_helper"

class CustomerAuthorizationCodeTest < ActiveSupport::TestCase
  def setup
    @customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}", status_id: CustomerStatus::NOTHING)
    @code = CustomerAuthorizationCode.issue!(
      subject: @customer,
      client_id: "test_client",
      redirect_uri: "https://example.com/callback",
      code_challenge: "test_challenge",
      code_challenge_method: "S256",
    )
  end

  test "inherits from GuestRecord" do
    assert_operator CustomerAuthorizationCode, :<, GuestRecord
  end

  test "belongs to customer" do
    association = CustomerAuthorizationCode.reflect_on_association(:customer)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "includes OidcAuthorizationCode concern" do
    assert_includes CustomerAuthorizationCode.ancestors, OidcAuthorizationCode
  end

  test "subject_association_name returns :customer" do
    assert_equal :customer, CustomerAuthorizationCode.subject_association_name
  end

  test "can be created with issue!" do
    assert_not_nil @code
    assert_equal @customer.id, @code.customer_id
    assert_equal "test_client", @code.client_id
  end

  test "code is generated automatically" do
    assert_not_nil @code.code
    assert_predicate @code.code, :present?
  end

  test "code is unique" do
    duplicate = CustomerAuthorizationCode.new(
      customer: @customer,
      code: @code.code,
      client_id: "another_client",
      redirect_uri: "https://example.com/callback",
      code_challenge: "another_challenge",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:code]
  end

  test "validates code presence" do
    code = CustomerAuthorizationCode.new(
      customer: @customer,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )
    code.code = nil

    assert_not code.valid?
    assert_not_empty code.errors[:code]
  end

  test "validates client_id presence" do
    code = CustomerAuthorizationCode.new(
      customer: @customer,
      code: "valid_code",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )
    code.client_id = nil

    assert_not code.valid?
    assert_not_empty code.errors[:client_id]
  end

  test "validates redirect_uri presence" do
    code = CustomerAuthorizationCode.new(
      customer: @customer,
      code: "valid_code",
      client_id: "test",
      code_challenge: "challenge",
      varnishable_at: 10.seconds.from_now,
    )
    code.redirect_uri = nil

    assert_not code.valid?
    assert_not_empty code.errors[:redirect_uri]
  end

  test "validates code_challenge presence" do
    code = CustomerAuthorizationCode.new(
      customer: @customer,
      code: "valid_code",
      client_id: "test",
      redirect_uri: "https://example.com",
      varnishable_at: 10.seconds.from_now,
    )
    code.code_challenge = nil

    assert_not code.valid?
    assert_not_empty code.errors[:code_challenge]
  end

  test "validates code_challenge_method inclusion" do
    code = CustomerAuthorizationCode.new(
      customer: @customer,
      code: "valid_code",
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
      code_challenge_method: "invalid",
      varnishable_at: 10.seconds.from_now,
    )

    assert_not code.valid?
    assert_not_empty code.errors[:code_challenge_method]
  end

  test "validates varnishable_at presence" do
    code = CustomerAuthorizationCode.new(
      customer: @customer,
      code: "valid_code",
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    code.varnishable_at = nil

    assert_not code.valid?
    assert_not_empty code.errors[:varnishable_at]
  end

  test "default acr is aal1" do
    assert_equal "aal1", @code.acr
  end

  test "default auth_method is empty string" do
    assert_equal "", @code.auth_method
  end

  test "expired? returns true when varnishable_at is in the past" do
    @code.update!(varnishable_at: 1.second.ago)

    assert_predicate @code, :expired?
  end

  test "expired? returns false when varnishable_at is in the future" do
    @code.update!(varnishable_at: 10.seconds.from_now)

    assert_not @code.expired?
  end

  test "consumed? returns true when consumed_at is set" do
    @code.update!(consumed_at: Time.current)

    assert_predicate @code, :consumed?
  end

  test "consumed? returns false when consumed_at is nil" do
    assert_not @code.consumed?
  end

  test "revoked? returns true when revoked_at is set" do
    @code.update!(revoked_at: Time.current)

    assert_predicate @code, :revoked?
  end

  test "revoked? returns false when revoked_at is nil" do
    assert_not @code.revoked?
  end

  test "usable? returns true when not expired, consumed, or revoked" do
    @code.update!(varnishable_at: 10.seconds.from_now, consumed_at: nil, revoked_at: nil)

    assert_predicate @code, :usable?
  end

  test "usable? returns false when expired" do
    @code.update!(varnishable_at: 1.second.ago)

    assert_not @code.usable?
  end

  test "usable? returns false when consumed" do
    @code.update!(consumed_at: Time.current)

    assert_not @code.usable?
  end

  test "usable? returns false when revoked" do
    @code.update!(revoked_at: Time.current)

    assert_not @code.usable?
  end

  test "consume! sets consumed_at" do
    @code.consume!

    assert_predicate @code.consumed_at, :present?
  end

  test "consume! raises when already consumed" do
    @code.consume!

    assert_raises(RuntimeError, "Authorization code already consumed") do
      @code.consume!
    end
  end

  test "consume! raises when revoked" do
    @code.revoke!

    assert_raises(RuntimeError, "Authorization code revoked") do
      @code.consume!
    end
  end

  test "consume! raises when expired" do
    @code.update!(varnishable_at: 1.second.ago)

    assert_raises(RuntimeError, "Authorization code expired") do
      @code.consume!
    end
  end

  test "revoke! sets revoked_at" do
    @code.revoke!

    assert_predicate @code.revoked_at, :present?
  end

  test "revoke! is idempotent" do
    @code.revoke!
    original_revoked_at = @code.revoked_at
    sleep(0.01)
    @code.revoke!

    assert_equal original_revoked_at, @code.revoked_at
  end

  test "verify_pkce returns true for valid verifier" do
    code_verifier = "test_verifier"
    expected_challenge = Base64.urlsafe_encode64(
      Digest::SHA256.digest(code_verifier),
      padding: false,
    )
    @code.update!(code_challenge: expected_challenge)

    assert @code.verify_pkce(code_verifier)
  end

  test "verify_pkce returns false for invalid verifier" do
    @code.update!(code_challenge: "valid_challenge")

    assert_not @code.verify_pkce("wrong_verifier")
  end

  test "verify_pkce returns false when code_verifier is blank" do
    assert_not @code.verify_pkce(nil)
    assert_not @code.verify_pkce("")
  end

  test "subject returns the associated customer" do
    assert_equal @customer, @code.subject
  end

  test "subject_id returns the customer_id" do
    assert_equal @customer.id, @code.subject_id
  end

  test "valid scope returns non-expired, non-consumed, non-revoked codes" do
    expired = CustomerAuthorizationCode.issue!(
      subject: @customer,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    expired.update!(varnishable_at: 1.second.ago)

    consumed = CustomerAuthorizationCode.issue!(
      subject: @customer,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    consumed.consume!

    revoked = CustomerAuthorizationCode.issue!(
      subject: @customer,
      client_id: "test",
      redirect_uri: "https://example.com",
      code_challenge: "challenge",
    )
    revoked.revoke!

    valid_codes = CustomerAuthorizationCode.valid.pluck(:id)

    assert_includes valid_codes, @code.id
    assert_not_includes valid_codes, expired.id
    assert_not_includes valid_codes, consumed.id
    assert_not_includes valid_codes, revoked.id
  end

  test "customer association loads customer correctly" do
    assert_equal @customer, @code.customer
    assert_equal @customer.id, @code.customer.id
  end

  test "timestamps are set on creation" do
    assert_not_nil @code.created_at
    assert_not_nil @code.updated_at
    assert_operator @code.created_at, :<=, @code.updated_at
  end

  test "association deletion: destroys when customer is destroyed" do
    @code.reload
    @customer.destroy

    assert_raise(ActiveRecord::RecordNotFound) { @code.reload }
  end

  test "issue! accepts optional parameters" do
    code = CustomerAuthorizationCode.issue!(
      subject: @customer,
      client_id: "test_client",
      redirect_uri: "https://example.com/callback",
      code_challenge: "challenge",
      code_challenge_method: "S256",
      scope: "openid profile",
      state: "random_state",
      nonce: "random_nonce",
      auth_method: ["password"],
      acr: "aal2",
    )

    assert_equal "openid profile", code.scope
    assert_equal "random_state", code.state
    assert_equal "random_nonce", code.nonce
    assert_equal '["password"]', code.auth_method
    assert_equal "aal2", code.acr
  end

  test "index on varnishable_at exists" do
    indexes = CustomerAuthorizationCode.connection.indexes("customer_authorization_codes")
    varnishable_index = indexes.find { |i| i.columns.include?("varnishable_at") }

    assert_not_nil varnishable_index, "Expected index on varnishable_at to exist"
  end

  test "index on customer_id exists" do
    indexes = CustomerAuthorizationCode.connection.indexes("customer_authorization_codes")
    customer_id_index = indexes.find { |i| i.columns.include?("customer_id") }

    assert_not_nil customer_id_index, "Expected index on customer_id to exist"
  end

  test "unique index on code exists" do
    indexes = CustomerAuthorizationCode.connection.indexes("customer_authorization_codes")
    code_index = indexes.find { |i| i.columns == ["code"] && i.unique }

    assert_not_nil code_index, "Expected unique index on code to exist"
  end
end
