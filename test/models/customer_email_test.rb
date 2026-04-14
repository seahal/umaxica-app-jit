# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_emails
# Database name: guest
#
#  id                        :bigint           not null, primary key
#  address                   :string           default(""), not null
#  address_bidx              :string
#  address_digest            :string
#  locked_at                 :datetime         default(Infinity), not null
#  notifiable                :boolean          default(TRUE), not null
#  otp_attempts_count        :integer          default(0), not null
#  otp_counter               :text             default(""), not null
#  otp_expires_at            :datetime         default(-Infinity), not null
#  otp_last_sent_at          :datetime         default(-Infinity), not null
#  otp_private_key           :string           default(""), not null
#  promotional               :boolean          default(TRUE), not null
#  subscribable              :boolean          default(TRUE), not null
#  verification_token_digest :binary
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_email_status_id  :bigint           default(1), not null
#  customer_id               :bigint           not null
#  public_id                 :string(21)       not null
#
# Indexes
#
#  index_customer_emails_on_address_bidx              (address_bidx) UNIQUE WHERE (address_bidx IS NOT NULL)
#  index_customer_emails_on_address_digest            (address_digest) UNIQUE WHERE (address_digest IS NOT NULL)
#  index_customer_emails_on_customer_email_status_id  (customer_email_status_id)
#  index_customer_emails_on_customer_id               (customer_id)
#  index_customer_emails_on_lower_address             (lower((address)::text)) UNIQUE
#  index_customer_emails_on_otp_last_sent_at          (otp_last_sent_at)
#  index_customer_emails_on_public_id                 (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_email_status_id => customer_email_statuses.id)
#  fk_rails_...  (customer_id => customers.id)
#
require "test_helper"

class CustomerEmailTest < ActiveSupport::TestCase
  setup do
    @customer = create_verified_customer_with_email(
      email_address: "customer-model-#{SecureRandom.hex(4)}@example.com",
    )
    @valid_attributes = {
      address: "customer-email@example.com",
      confirm_policy: true,
      customer: @customer,
    }.freeze
  end

  test "blocks destroying an oauth-linked email" do
    customer_email = CustomerEmail.create!(@valid_attributes.merge(customer_email_status_id: CustomerEmailStatus::OAUTH_LINKED))

    assert_raises(ActiveRecord::RecordNotDestroyed) { customer_email.destroy! }
    assert_includes customer_email.errors[:base], "cannot delete a protected email address"
    assert_equal CustomerEmailStatus::OAUTH_LINKED, customer_email.reload.customer_email_status_id
  end

  test "should inherit from GuestRecord" do
    assert_operator CustomerEmail, :<, GuestRecord
  end

  test "should include Email concern" do
    assert_includes CustomerEmail.included_modules, Email
  end

  test "should be valid with valid email and policy confirmation" do
    customer_email = CustomerEmail.new(@valid_attributes)

    assert_predicate customer_email, :valid?
  end

  test "should require valid email format" do
    customer_email = CustomerEmail.new(@valid_attributes.merge(address: "not-an-email"))

    assert_not customer_email.valid?
    assert_predicate customer_email.errors[:address], :any?
  end

  test "should require email presence" do
    customer_email = CustomerEmail.new(@valid_attributes.except(:address))
    customer_email.address = ""

    assert_not customer_email.valid?
    assert_predicate customer_email.errors[:address], :any?
  end

  test "should require policy confirmation on create" do
    customer_email = CustomerEmail.new(@valid_attributes.merge(confirm_policy: false))

    assert_not customer_email.valid?
    assert_predicate customer_email.errors[:confirm_policy], :any?
  end

  test "should require unique email addresses" do
    CustomerEmail.create!(@valid_attributes)
    duplicate = CustomerEmail.new(@valid_attributes)

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:address], :any?
  end

  test "should downcase email address before saving" do
    customer_email = CustomerEmail.new(@valid_attributes.merge(address: "CUSTOMER@EXAMPLE.COM"))
    customer_email.save!

    assert_equal "customer@example.com", customer_email.address
  end

  test "should encrypt email address" do
    customer_email = CustomerEmail.create!(@valid_attributes)
    query = "SELECT address FROM #{CustomerEmail.table_name} WHERE id = '#{customer_email.id}'"
    raw_data = CustomerEmail.connection.execute(query).first

    assert_not_equal @valid_attributes[:address], raw_data["address"] if raw_data
  end

  test "sets address_digest from normalized input" do
    customer_email = CustomerEmail.create!(
      raw_address: "TEST@EXAMPLE.COM",
      confirm_policy: true,
      customer: @customer,
    )
    expected = IdentifierBlindIndex.bidx_for_email("test@example.com")

    assert_equal expected, customer_email.address_digest
  end

  test "to_param uses public_id" do
    customer_email = CustomerEmail.create!(@valid_attributes)

    assert_equal customer_email.public_id, customer_email.to_param
  end

  # Boundary: MAX+1 - creation must fail
  test "enforces maximum emails per customer" do
    customer = Customer.create!(
      status_id: CustomerStatus::ACTIVE,
      visibility_id: CustomerVisibility::CUSTOMER,
    )

    Prosopite.pause do
      CustomerEmail::MAX_EMAILS_PER_CUSTOMER.times do |i|
        CustomerEmail.create!(
          address: "cust#{i}@example.com",
          confirm_policy: true,
          customer: customer,
        )
      end
    end

    extra = CustomerEmail.new(
      address: "overflow@example.com",
      confirm_policy: true,
      customer: customer,
    )

    assert_not extra.valid?
    assert_includes extra.errors[:base], "exceeds maximum emails per customer (#{CustomerEmail::MAX_EMAILS_PER_CUSTOMER})"
  end

  # Boundary: one below the limit - creation must succeed
  test "allows creating emails up to one below the limit" do
    customer = Customer.create!(
      status_id: CustomerStatus::ACTIVE,
      visibility_id: CustomerVisibility::CUSTOMER,
    )
    below_limit = CustomerEmail::MAX_EMAILS_PER_CUSTOMER - 1

    Prosopite.pause do
      (below_limit - 1).times do |i|
        CustomerEmail.create!(
          address: "cust-below#{i}@example.com",
          confirm_policy: true,
          customer: customer,
        )
      end
    end

    email_at_below_limit = CustomerEmail.new(
      address: "cust-at-below-limit@example.com",
      confirm_policy: true,
      customer: customer,
    )

    assert_predicate email_at_below_limit, :valid?
  end

  # Boundary: exactly at the limit - the final permitted creation must succeed
  test "allows creating the email that reaches the limit" do
    customer = Customer.create!(
      status_id: CustomerStatus::ACTIVE,
      visibility_id: CustomerVisibility::CUSTOMER,
    )
    limit = CustomerEmail::MAX_EMAILS_PER_CUSTOMER

    Prosopite.pause do
      (limit - 1).times do |i|
        CustomerEmail.create!(
          address: "cust-filling#{i}@example.com",
          confirm_policy: true,
          customer: customer,
        )
      end
    end

    last_permitted = CustomerEmail.new(
      address: "cust-last-permitted@example.com",
      confirm_policy: true,
      customer: customer,
    )

    assert_predicate last_permitted, :valid?
    assert_nothing_raised { last_permitted.save! }
  end

  # Equivalence: limit is counted per customer - another customer is unaffected
  test "email limit is isolated per customer" do
    saturated = Customer.create!(
      status_id: CustomerStatus::ACTIVE,
      visibility_id: CustomerVisibility::CUSTOMER,
    )

    Prosopite.pause do
      CustomerEmail::MAX_EMAILS_PER_CUSTOMER.times do |i|
        CustomerEmail.create!(
          address: "cust-saturated#{i}@example.com",
          confirm_policy: true,
          customer: saturated,
        )
      end
    end

    email_for_other = CustomerEmail.new(
      address: "cust-other@example.com",
      confirm_policy: true,
      customer: @customer,
    )

    assert_predicate email_for_other, :valid?
  end

  # Equivalence: limit validation only fires on create, not on update
  test "email limit is not checked on update" do
    customer = Customer.create!(
      status_id: CustomerStatus::ACTIVE,
      visibility_id: CustomerVisibility::CUSTOMER,
    )

    Prosopite.pause do
      CustomerEmail::MAX_EMAILS_PER_CUSTOMER.times do |i|
        CustomerEmail.create!(
          address: "cust-update#{i}@example.com",
          confirm_policy: true,
          customer: customer,
        )
      end
    end

    existing = CustomerEmail.where(customer: customer).first
    existing.notifiable = false

    assert_predicate existing, :valid?
    assert_nothing_raised { existing.save! }
  end

  test "generate_verification_token sets digest and returns raw token" do
    email = CustomerEmail.create!(
      address: "verification-#{SecureRandom.hex(4)}@example.com",
      confirm_policy: true,
      customer: @customer,
    )

    raw_token = email.generate_verification_token

    assert_predicate raw_token, :present?
    assert_predicate email.verification_token_digest, :present?
    assert_not_includes email.attributes.values, raw_token
  end

  test "verify_verification_token returns true with correct token" do
    email = CustomerEmail.create!(
      address: "verify-#{SecureRandom.hex(4)}@example.com",
      confirm_policy: true,
      customer: @customer,
    )
    raw_token = email.generate_verification_token

    assert email.verify_verification_token(raw_token)
  end

  test "verify_verification_token returns false with wrong token" do
    email = CustomerEmail.create!(
      address: "verify-wrong-#{SecureRandom.hex(4)}@example.com",
      confirm_policy: true,
      customer: @customer,
    )
    email.generate_verification_token

    assert_not email.verify_verification_token("wrong_token_value")
  end

  test "verify_verification_token returns false when raw_token is blank" do
    email = CustomerEmail.create!(
      address: "verify-blank-#{SecureRandom.hex(4)}@example.com",
      confirm_policy: true,
      customer: @customer,
    )
    email.generate_verification_token

    assert_not email.verify_verification_token("")
    assert_not email.verify_verification_token(nil)
  end

  test "verify_verification_token returns false when digest is blank" do
    email = CustomerEmail.create!(
      address: "verify-no-digest-#{SecureRandom.hex(4)}@example.com",
      confirm_policy: true,
      customer: @customer,
    )

    assert_not email.verify_verification_token("some_token")
  end
end
