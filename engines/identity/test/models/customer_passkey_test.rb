# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_passkeys
# Database name: guest
#
#  id           :bigint           not null, primary key
#  description  :string           default(""), not null
#  last_used_at :datetime
#  public_key   :text             not null
#  sign_count   :bigint           default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  customer_id  :bigint           not null
#  external_id  :uuid             not null
#  public_id    :string(21)       not null
#  status_id    :bigint           default(1), not null
#  webauthn_id  :string           default(""), not null
#
# Indexes
#
#  index_customer_passkeys_on_customer_id  (customer_id)
#  index_customer_passkeys_on_public_id    (public_id) UNIQUE
#  index_customer_passkeys_on_status_id    (status_id)
#  index_customer_passkeys_on_webauthn_id  (webauthn_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (status_id => customer_passkey_statuses.id)
#

require "test_helper"

class CustomerPasskeyTest < ActiveSupport::TestCase
  def setup
    CustomerPasskeyStatus.find_or_create_by!(id: CustomerPasskeyStatus::ACTIVE)
    CustomerEmailStatus.find_or_create_by!(id: CustomerEmailStatus::VERIFIED)
    @customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}")
    CustomerEmail.create!(
      customer: @customer,
      address: "passkey-test-#{SecureRandom.hex(4)}@example.com",
      customer_email_status_id: CustomerEmailStatus::VERIFIED,
    )
    @passkey = CustomerPasskey.new(
      customer: @customer,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "test-key",
      description: "My Passkey",
      sign_count: 0,
    )
  end

  test "should be valid" do
    assert_predicate @passkey, :valid?
  end

  test "defaults status_id to active" do
    passkey = CustomerPasskey.new(customer: @customer, webauthn_id: "id3", public_key: "key3")

    assert_equal CustomerPasskeyStatus::ACTIVE, passkey.status_id
  end

  test "status association uses status_id" do
    status = CustomerPasskeyStatus.find(CustomerPasskeyStatus::ACTIVE)
    @passkey.status = status
    @passkey.save!

    assert_equal status, @passkey.reload.status
    assert_equal status.id, @passkey.status_id
  end

  test "should require webauthn_id and public_key" do
    @passkey.webauthn_id = nil

    assert_not @passkey.valid?
    @passkey.webauthn_id = "test-id"

    @passkey.public_key = nil

    assert_not @passkey.valid?
  end

  test "should set default sign_count and description" do
    passkey = CustomerPasskey.new(customer: @customer, webauthn_id: "id2", public_key: "key2")
    passkey.save

    assert_not_nil passkey.external_id
    assert_equal 0, passkey.sign_count
    assert_not_nil passkey.description
  end

  test "should validate uniqueness of webauthn_id" do
    @passkey.save!
    duplicate = @passkey.dup

    assert_not duplicate.valid?
  end

  test "enforces maximum passkeys per customer" do
    CustomerPasskey::MAX_PASSKEYS_PER_CUSTOMER.times do |i|
      CustomerPasskey.create!(
        customer: @customer,
        webauthn_id: SecureRandom.uuid,
        external_id: SecureRandom.uuid,
        public_key: "test-key-#{i}",
        description: "Key #{i}",
      )
    end

    extra_passkey = CustomerPasskey.new(
      customer: @customer,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "overflow-key",
      description: "Overflow key",
    )

    assert_not extra_passkey.valid?
    assert_includes extra_passkey.errors[:base], "exceeds maximum passkeys per customer (#{CustomerPasskey::MAX_PASSKEYS_PER_CUSTOMER})"
  end

  test "sign_count zero is valid at lower boundary" do
    @passkey.sign_count = 0

    assert_predicate @passkey, :valid?
  end

  test "4th passkey succeeds when 3 exist for customer" do
    Prosopite.pause do
      3.times do |i|
        CustomerPasskey.create!(
          customer: @customer,
          webauthn_id: SecureRandom.uuid,
          external_id: SecureRandom.uuid,
          public_key: "key-below-#{i}",
          description: "Key #{i}",
        )
      end
    end

    fourth = CustomerPasskey.new(
      customer: @customer,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "key-at-4",
      description: "Fourth Key",
    )

    assert_predicate fourth, :valid?
    assert fourth.save
  end

  test "4th passkey is last allowed when exactly 4 for customer" do
    Prosopite.pause do
      3.times do |i|
        CustomerPasskey.create!(
          customer: @customer,
          webauthn_id: SecureRandom.uuid,
          external_id: SecureRandom.uuid,
          public_key: "key-limit-#{i}",
          description: "Key #{i}",
        )
      end
    end

    fourth = CustomerPasskey.new(
      customer: @customer,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "key-4th",
      description: "Fourth Key",
    )

    assert_predicate fourth, :valid?
    assert fourth.save
    assert_equal 4, CustomerPasskey.where(customer: @customer).count
  end

  test "5th passkey fails when 4 exist for customer" do
    Prosopite.pause do
      CustomerPasskey::MAX_PASSKEYS_PER_CUSTOMER.times do |i|
        CustomerPasskey.create!(
          customer: @customer,
          webauthn_id: SecureRandom.uuid,
          external_id: SecureRandom.uuid,
          public_key: "key-max-#{i}",
          description: "Key #{i}",
        )
      end
    end

    fifth = CustomerPasskey.new(
      customer: @customer,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "key-above-limit",
      description: "Fifth Key",
    )

    assert_not fifth.valid?
    assert_includes fifth.errors[:base], "exceeds maximum passkeys per customer (#{CustomerPasskey::MAX_PASSKEYS_PER_CUSTOMER})"
  end

  test "passkey limit is per-customer and isolates between customers" do
    other_customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}")
    CustomerEmail.create!(
      customer: other_customer,
      address: "other-customer-#{SecureRandom.hex(4)}@example.com",
      customer_email_status_id: CustomerEmailStatus::VERIFIED,
    )

    Prosopite.pause do
      CustomerPasskey::MAX_PASSKEYS_PER_CUSTOMER.times do |i|
        CustomerPasskey.create!(
          customer: @customer,
          webauthn_id: SecureRandom.uuid,
          external_id: SecureRandom.uuid,
          public_key: "key-first-customer-#{i}",
          description: "Key #{i}",
        )
      end
    end

    other_passkey = CustomerPasskey.new(
      customer: other_customer,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "other-customer-key",
      description: "Other Customer Key",
    )

    assert_predicate other_passkey, :valid?
    assert other_passkey.save
  end

  test "updating existing passkey does not re-run limit check" do
    Prosopite.pause do
      CustomerPasskey::MAX_PASSKEYS_PER_CUSTOMER.times do |i|
        CustomerPasskey.create!(
          customer: @customer,
          webauthn_id: SecureRandom.uuid,
          external_id: SecureRandom.uuid,
          public_key: "key-max-#{i}",
          description: "Key #{i}",
        )
      end
    end

    existing = CustomerPasskey.where(customer: @customer).first
    existing.description = "Updated description"

    assert existing.save
    assert_predicate existing, :valid?
  end

  test "sign_count cannot be negative" do
    @passkey.sign_count = -1

    assert_not @passkey.valid?
    assert_not_empty @passkey.errors[:sign_count]
  end

  test "association deletion: destroys when customer is destroyed" do
    @passkey.save!
    @customer.destroy
    assert_raise(ActiveRecord::RecordNotFound) { @passkey.reload }
  end

  test "is invalid on create when customer has no verified recovery identity" do
    customer_without_identity = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}")
    passkey = CustomerPasskey.new(
      customer: customer_without_identity,
      webauthn_id: SecureRandom.uuid,
      external_id: SecureRandom.uuid,
      public_key: "test-key",
      description: "No Identity",
      sign_count: 0,
    )

    assert_not passkey.valid?
    assert_includes passkey.errors[:base], Customer::RECOVERY_IDENTITY_REQUIRED_MESSAGE
  end
end
