# typed: false
# frozen_string_literal: true

require "test_helper"
require "base64"

class CustomerIdentityTest < ActiveSupport::TestCase
  setup do
    # Seed CustomerStatus
    CustomerStatus.find_or_create_by!(id: CustomerStatus::ACTIVE)
    CustomerStatus.find_or_create_by!(id: CustomerStatus::NOTHING)
    CustomerStatus.find_or_create_by!(id: CustomerStatus::RESERVED)

    # Seed CustomerVisibility
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::NOBODY)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::CUSTOMER)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::STAFF)
    CustomerVisibility.find_or_create_by!(id: CustomerVisibility::BOTH)

    # Seed CustomerEmailStatus
    [1, 2, 3, 4, 5, 6, 7].each { |id| CustomerEmailStatus.find_or_create_by!(id: id) }

    # Seed CustomerTelephoneStatus
    [1, 2, 3, 4, 5, 6, 7].each { |id| CustomerTelephoneStatus.find_or_create_by!(id: id) }

    # Seed CustomerSecretStatus
    [1, 2, 3, 4, 5, 6].each { |id| CustomerSecretStatus.find_or_create_by!(id: id) }

    # Seed CustomerSecretKind
    [1, 2, 3, 4].each { |id| CustomerSecretKind.find_or_create_by!(id: id) }

    # Seed CustomerPasskeyStatus
    [1, 2, 3, 4, 5].each { |id| CustomerPasskeyStatus.find_or_create_by!(id: id) }
  end

  test "customer tracks verified recovery identity through customer email and telephone" do
    customer = Customer.create!

    assert_not customer.has_verified_recovery_identity?

    customer.customer_emails.create!(
      address: "customer-#{SecureRandom.hex(4)}@example.com",
      customer_email_status_id: CustomerEmailStatus::VERIFIED,
      confirm_policy: "1",
    )

    assert_predicate customer, :verified_email?
    assert_predicate customer, :has_verified_recovery_identity?

    customer.customer_telephones.create!(
      number: "+8190#{SecureRandom.random_number(10**8).to_s.rjust(8, "0")}",
      customer_telephone_status_id: CustomerTelephoneStatus::VERIFIED,
      confirm_policy: "1",
    )

    assert_predicate customer, :verified_telephone?
  end

  test "customer secret requires verified recovery identity" do
    customer = Customer.create!
    secret = CustomerSecret.new(customer: customer, name: "login", password: "a" * 32)

    assert_not secret.valid?
    assert_includes secret.errors[:base], Customer::RECOVERY_IDENTITY_REQUIRED_MESSAGE
  end

  test "customer passkey requires verified recovery identity" do
    customer = Customer.create!
    passkey = CustomerPasskey.new(
      customer: customer,
      webauthn_id: Base64.urlsafe_encode64("customer_passkey", padding: false),
      external_id: SecureRandom.uuid,
      public_key: "public_key",
      description: "Customer Passkey",
    )

    assert_not passkey.valid?
    assert_includes passkey.errors[:base], Customer::RECOVERY_IDENTITY_REQUIRED_MESSAGE
  end
end
