# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_secrets
# Database name: guest
#
#  id                        :bigint           not null, primary key
#  expires_at                :datetime         default(Infinity), not null
#  last_used_at              :datetime
#  name                      :string           default(""), not null
#  password_digest           :string           default(""), not null
#  uses_remaining            :integer          default(1), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_id               :bigint           not null
#  customer_secret_kind_id   :bigint           default(1), not null
#  customer_secret_status_id :bigint           default(1), not null
#  public_id                 :string(21)       not null
#
# Indexes
#
#  index_customer_secrets_on_customer_id                (customer_id)
#  index_customer_secrets_on_customer_secret_kind_id    (customer_secret_kind_id)
#  index_customer_secrets_on_customer_secret_status_id  (customer_secret_status_id)
#  index_customer_secrets_on_expires_at                 (expires_at)
#  index_customer_secrets_on_public_id                  (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#  fk_rails_...  (customer_secret_kind_id => customer_secret_kinds.id)
#  fk_rails_...  (customer_secret_status_id => customer_secret_statuses.id)
#

require "test_helper"

class CustomerSecretTest < ActiveSupport::TestCase
  setup do
    CustomerSecretStatus.find_or_create_by!(id: CustomerSecretStatus::ACTIVE)
    CustomerSecretStatus.find_or_create_by!(id: CustomerSecretStatus::USED)
    CustomerSecretStatus.find_or_create_by!(id: CustomerSecretStatus::EXPIRED)
    CustomerSecretStatus.find_or_create_by!(id: CustomerSecretStatus::NOTHING)
    CustomerSecretKind.find_or_create_by!(id: CustomerSecretKind::LOGIN)
    CustomerSecretKind.find_or_create_by!(id: CustomerSecretKind::TOTP)
    CustomerSecretKind.find_or_create_by!(id: CustomerSecretKind::RECOVERY)
    CustomerSecretKind.find_or_create_by!(id: CustomerSecretKind::API)
    CustomerEmailStatus.find_or_create_by!(id: CustomerEmailStatus::VERIFIED)

    @customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}")
    CustomerEmail.create!(
      customer: @customer,
      address: "secret-test-#{SecureRandom.hex(4)}@example.com",
      customer_email_status_id: CustomerEmailStatus::VERIFIED,
    )

    @login_kind = CustomerSecretKind.find(CustomerSecretKind::LOGIN)
    @active_status = CustomerSecretStatus.find(CustomerSecretStatus::ACTIVE)
  end

  test "allows up to the maximum number of secrets per customer" do
    CustomerSecret::MAX_SECRETS_PER_CUSTOMER.times do
      create_secret!
    end

    assert_equal CustomerSecret::MAX_SECRETS_PER_CUSTOMER,
                 CustomerSecret.where(customer: @customer).count
  end

  test "rejects creating more than the maximum secrets per customer" do
    CustomerSecret::MAX_SECRETS_PER_CUSTOMER.times { create_secret! }

    assert_raises(ActiveRecord::RecordInvalid) { create_secret! }
  end

  test "10th secret succeeds when 9 exist for customer" do
    Prosopite.pause do
      9.times do
        create_secret!
      end
    end

    tenth = CustomerSecret.new(
      customer: @customer,
      name: "Tenth Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_predicate tenth, :valid?
    assert tenth.save
  end

  test "10th secret is last allowed when exactly 10 for customer" do
    Prosopite.pause do
      9.times do
        create_secret!
      end
    end

    tenth = CustomerSecret.new(
      customer: @customer,
      name: "Tenth Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_predicate tenth, :valid?
    assert tenth.save
    assert_equal 10, CustomerSecret.where(customer: @customer).count
  end

  test "11th secret fails when 10 exist for customer" do
    Prosopite.pause do
      CustomerSecret::MAX_SECRETS_PER_CUSTOMER.times do
        create_secret!
      end
    end

    eleventh = CustomerSecret.new(
      customer: @customer,
      name: "Eleventh Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_not eleventh.valid?
    assert_includes eleventh.errors[:base], "exceeds maximum secrets per customer (#{CustomerSecret::MAX_SECRETS_PER_CUSTOMER})"
  end

  test "secret limit is per-customer and isolates between customers" do
    other_customer = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}")
    CustomerEmail.create!(
      customer: other_customer,
      address: "other-secret-#{SecureRandom.hex(4)}@example.com",
      customer_email_status_id: CustomerEmailStatus::VERIFIED,
    )

    Prosopite.pause do
      CustomerSecret::MAX_SECRETS_PER_CUSTOMER.times do
        create_secret!
      end
    end

    other_secret = CustomerSecret.new(
      customer: other_customer,
      name: "Other Customer Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_predicate other_secret, :valid?
    assert other_secret.save
  end

  test "name exactly 255 characters is valid at upper boundary" do
    record = CustomerSecret.new(
      customer: @customer,
      name: "a" * 255,
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_predicate record, :valid?
  end

  test "name 256 characters is invalid above upper boundary" do
    record = CustomerSecret.new(
      customer: @customer,
      name: "a" * 256,
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_not record.valid?
    assert_not_empty record.errors[:name]
  end

  test "issue! returns raw secret and persists a digest" do
    record, raw_secret = CustomerSecret.issue!(
      name: "API Key",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_predicate record, :persisted?
    assert_predicate raw_secret, :present?
    assert record.authenticate(raw_secret)
    assert_not_includes record.attributes.values, raw_secret
  end

  test "verify_and_consume! decrements uses_remaining" do
    record, raw_secret = CustomerSecret.issue!(
      name: "API Key",
      customer: @customer,
      uses: 2,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert record.verify_and_consume!(raw_secret)
    assert_equal 1, record.reload.uses_remaining
  end

  test "verify_and_consume! marks used when uses_remaining reaches zero" do
    record, raw_secret = CustomerSecret.issue!(
      name: "API Key",
      customer: @customer,
      uses: 1,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert record.verify_and_consume!(raw_secret)
    assert_equal CustomerSecretStatus::USED, record.reload.customer_secret_status_id
  end

  test "usable_for_secret_sign_in returns true when now equals expires_at" do
    freeze_time do
      record, _raw = CustomerSecret.issue!(
        name: "Boundary Test",
        customer: @customer,
        customer_secret_kind_id: CustomerSecretKind::LOGIN,
      )

      assert record.usable_for_secret_sign_in?(now: record.expires_at)
    end
  end

  test "usable_for_secret_sign_in returns false when now is one second past expires_at" do
    freeze_time do
      record, _raw = CustomerSecret.issue!(
        name: "Boundary Test",
        customer: @customer,
        expires_at: 1.minute.from_now,
        customer_secret_kind_id: CustomerSecretKind::LOGIN,
      )

      assert_not record.usable_for_secret_sign_in?(now: record.expires_at + 1.second)
    end
  end

  test "usable_for_secret_sign_in returns true when expires_at is infinity" do
    record, _raw = CustomerSecret.issue!(
      name: "Infinity Test",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_equal Float::INFINITY, record.expires_at
    assert record.usable_for_secret_sign_in?(now: Time.current)
    assert record.usable_for_secret_sign_in?(now: 100.years.from_now)
  end

  test "login_secret? predicate returns true for LOGIN kind" do
    record = CustomerSecret.new(
      customer: @customer,
      name: "Key",
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_predicate record, :login_secret?
    assert_not record.totp_secret?
    assert_not record.recovery_secret?
    assert_not record.api_secret?
  end

  test "totp_secret? predicate returns true for TOTP kind" do
    record = CustomerSecret.new(
      customer: @customer,
      name: "Key",
      customer_secret_kind_id: CustomerSecretKind::TOTP,
    )

    assert_predicate record, :totp_secret?
    assert_not record.login_secret?
  end

  test "recovery_secret? predicate returns true for RECOVERY kind" do
    record = CustomerSecret.new(
      customer: @customer,
      name: "Key",
      customer_secret_kind_id: CustomerSecretKind::RECOVERY,
    )

    assert_predicate record, :recovery_secret?
    assert_not record.login_secret?
  end

  test "api_secret? predicate returns true for API kind" do
    record = CustomerSecret.new(
      customer: @customer,
      name: "Key",
      customer_secret_kind_id: CustomerSecretKind::API,
    )

    assert_predicate record, :api_secret?
    assert_not record.login_secret?
  end

  test "association deletion: destroys when customer is destroyed" do
    record, _raw = CustomerSecret.issue!(
      name: "Cleanup Test",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )
    @customer.destroy
    assert_raise(ActiveRecord::RecordNotFound) { record.reload }
  end

  test "is invalid on create when customer has no verified recovery identity" do
    customer_without_identity = Customer.create!(public_id: "c_#{SecureRandom.hex(8)}")

    record = CustomerSecret.new(
      customer: customer_without_identity,
      name: "No Identity Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_not record.valid?
    assert_includes record.errors[:base], Customer::RECOVERY_IDENTITY_REQUIRED_MESSAGE
  end

  test "public_id is automatically generated on create" do
    record = CustomerSecret.create!(
      customer: @customer,
      name: "Test Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_predicate record.public_id, :present?
    assert_equal 21, record.public_id.length
  end

  test "to_param returns public_id" do
    record = CustomerSecret.create!(
      customer: @customer,
      name: "Test Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    assert_equal record.public_id, record.to_param
  end

  test "value= sets password" do
    record = CustomerSecret.new(customer: @customer, customer_secret_kind_id: CustomerSecretKind::LOGIN)
    record.value = "test_secret"

    assert_equal "test_secret", record.password
  end

  test "value returns password" do
    record = CustomerSecret.new(
      customer: @customer, customer_secret_kind_id: CustomerSecretKind::LOGIN,
      password: "test_secret",
    )

    assert_equal "test_secret", record.value
  end

  test "generate_raw_secret returns correct length" do
    secret = CustomerSecret.generate_raw_secret(length: 32)

    assert_equal 32, secret.length
  end

  test "generate_raw_secret uses base58 alphabet" do
    secret = CustomerSecret.generate_raw_secret(length: 100)

    assert_match(/\A[A-Za-z0-9]+\z/, secret)
    assert_equal 100, secret.length
  end

  test "verify_for_secret_sign_in! succeeds with valid secret" do
    record, raw_secret = CustomerSecret.issue!(
      name: "Test Secret",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    result = record.verify_for_secret_sign_in!(raw_secret)

    assert result
    assert_not_nil record.reload.last_used_at
  end

  test "verify_for_secret_sign_in! fails with invalid secret" do
    record, _raw = CustomerSecret.issue!(
      name: "Test Secret",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )

    result = record.verify_for_secret_sign_in!("wrong_secret")

    assert_not result
  end

  test "verify_for_secret_sign_in! decrements uses_remaining for one-time secret" do
    record, raw_secret = CustomerSecret.issue!(
      name: "Test Secret",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::RECOVERY,
      uses: 1,
    )

    record.verify_for_secret_sign_in!(raw_secret)

    assert_equal 0, record.reload.uses_remaining
  end

  test "verify_for_secret_sign_in! marks as used when uses_remaining reaches zero" do
    record, raw_secret = CustomerSecret.issue!(
      name: "Test Secret",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::RECOVERY,
      uses: 1,
    )

    record.verify_for_secret_sign_in!(raw_secret)

    assert_equal 4, record.reload.customer_secret_status_id
  end

  test "verify_for_secret_sign_in! fails when expired" do
    record, raw_secret = CustomerSecret.issue!(
      name: "Test Secret",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
      expires_at: 1.hour.ago,
    )

    result = record.verify_for_secret_sign_in!(raw_secret)

    assert_not result
  end

  test "verify_for_secret_sign_in! fails when status not allowed" do
    record, raw_secret = CustomerSecret.issue!(
      name: "Test Secret",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )
    record.update!(customer_secret_status_id: CustomerSecretStatus::EXPIRED)

    result = record.verify_for_secret_sign_in!(raw_secret)

    assert_not result
  end

  test "allowed_for_secret_sign_in scope returns active login secrets" do
    record, _raw = CustomerSecret.issue!(
      name: "Active Login Secret",
      customer: @customer,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
    )
    CustomerSecret.create!(
      customer: @customer,
      name: "Expired Secret",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind_id: CustomerSecretKind::LOGIN,
      customer_secret_status_id: CustomerSecretStatus::EXPIRED,
    )

    allowed = CustomerSecret.allowed_for_secret_sign_in

    assert_includes allowed, record
    assert_not_includes allowed, CustomerSecret.find_by(name: "Expired Secret")
  end

  private

  def create_secret!
    CustomerSecret.create!(
      customer: @customer,
      name: "Secret-#{SecureRandom.hex(4)}",
      password: secure_secret,
      password_confirmation: secure_secret,
      customer_secret_kind: @login_kind,
      customer_secret_status: @active_status,
    )
  end

  def secure_secret
    SecureRandom.base58(Secret::SECRET_PASSWORD_LENGTH)
  end
end
