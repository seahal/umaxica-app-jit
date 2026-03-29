# typed: false
# frozen_string_literal: true

require "test_helper"

class AuthTokenServiceTest < ActiveSupport::TestCase
  private

  def ensure_customer_reference_records!
    CustomerStatus.find_or_create_by!(id: CustomerStatus::ACTIVE)
    CustomerStatus.find_or_create_by!(id: CustomerStatus::NOTHING)
    CustomerStatus.find_or_create_by!(id: CustomerStatus::RESERVED)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::NOBODY)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::CUSTOMER)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::STAFF)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::BOTH)
  end
  test "encode returns nil for nil resource" do
    result = Auth::TokenService.encode(nil, host: "example.com")

    assert_nil result
  end

  test "encode returns nil for blank host" do
    user = users(:one)
    result = Auth::TokenService.encode(user, host: "")

    assert_nil result
  end

  test "decode returns nil for blank token" do
    result = Auth::TokenService.decode("", host: "example.com", resource_type: "user")

    assert_nil result
  end

  test "decode returns nil for blank host" do
    result = Auth::TokenService.decode("some_token", host: "", resource_type: "user")

    assert_nil result
  end

  test "extract_subject returns subject from payload" do
    payload = { "sub" => 123 }

    assert_equal 123, Auth::TokenService.extract_subject(payload)
  end

  test "extract_act returns act from payload" do
    payload = { "act" => "staff" }

    assert_equal "staff", Auth::TokenService.extract_act(payload)
  end

  test "extract_session_id returns sid from payload" do
    payload = { "sid" => "abc123" }

    assert_equal "abc123", Auth::TokenService.extract_session_id(payload)
  end

  test "extract_jti returns jti from payload" do
    payload = { "jti" => "xyz789" }

    assert_equal "xyz789", Auth::TokenService.extract_jti(payload)
  end

  test "validate_actor_claim! returns true for matching user" do
    payload = { "act" => "user" }

    assert Auth::TokenService.validate_actor_claim!(payload, "user")
  end

  test "validate_actor_claim! returns false for mismatched actor" do
    payload = { "act" => "user" }

    assert_not Auth::TokenService.validate_actor_claim!(payload, "staff")
  end

  test "validate_actor_claim! returns true for matching customer" do
    payload = { "act" => "customer" }

    assert Auth::TokenService.validate_actor_claim!(payload, "customer")
  end

  test "encode creates valid token that can be decoded" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    assert_predicate token, :present?

    payload = Auth::TokenService.decode(token, host: "example.com", resource_type: "user")

    assert_predicate payload, :present?
    assert_equal user.id, payload["sub"]
  end

  test "decode rejects token when resource_type issuer/type do not match" do
    user = users(:one)
    token = Auth::TokenService.encode(
      user, host: "example.com", session_public_id: "sid123",
            resource_type: "user",
    )

    assert_nil Auth::TokenService.decode(token, host: "example.com", resource_type: "staff")
  end

  test "encode creates valid customer token that can be decoded" do
    ensure_customer_reference_records!
    customer = Customer.create!
    token = Auth::TokenService.encode(
      customer, host: "example.com", session_public_id: "sid999",
                resource_type: "customer",
    )

    assert_predicate token, :present?

    payload = Auth::TokenService.decode(token, host: "example.com", resource_type: "customer")

    assert_predicate payload, :present?
    assert_equal customer.id, payload["sub"]
    assert_equal "customer", payload["act"]
  end
end
