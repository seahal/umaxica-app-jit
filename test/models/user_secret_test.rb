# frozen_string_literal: true

# == Schema Information
#
# Table name: user_secrets
#
#  id                             :uuid             not null, primary key
#  user_id                        :uuid             not null
#  password_digest                :string           default(""), not null
#  last_used_at                   :datetime         default("-infinity"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  user_identity_secret_status_id :string(255)      default("ACTIVE"), not null
#  name                           :string           default(""), not null
#  expires_at                     :datetime         default("infinity"), not null
#  uses_remaining                 :integer          default(1), not null
#
# Indexes
#
#  index_user_secrets_on_expires_at                      (expires_at)
#  index_user_secrets_on_user_id                         (user_id)
#  index_user_secrets_on_user_identity_secret_status_id  (user_identity_secret_status_id)
#

require "test_helper"
require "concurrent"

class UserSecretTest < ActiveSupport::TestCase
  setup do
    UserStatus.find_or_create_by!(id: "NEYO")
    # Also need UserSecretStatus as 'ACTIVE', 'USED', 'EXPIRED' are used in tests
    UserSecretStatus.find_or_create_by!(id: "ACTIVE")
    UserSecretStatus.find_or_create_by!(id: "USED")
    UserSecretStatus.find_or_create_by!(id: "EXPIRED")

    @user =
      User.create!(public_id: "u_#{SecureRandom.hex(8)}") do |u|
        u.status_id = "NEYO"
      end
  end

  test "allows up to the maximum number of secrets per user" do
    UserSecret::MAX_SECRETS_PER_USER.times do
      create_secret!
    end

    assert_equal UserSecret::MAX_SECRETS_PER_USER,
                 UserSecret.where(user: @user).count
  end

  test "rejects creating more than the maximum secrets per user" do
    UserSecret::MAX_SECRETS_PER_USER.times { create_secret! }

    assert_raises(ActiveRecord::RecordInvalid) { create_secret! }
  end

  test "issue! returns raw secret and persists a digest" do
    record, raw_secret = UserSecret.issue!(name: "API Key", user: @user)

    assert_predicate record, :persisted?
    assert_predicate raw_secret, :present?
    assert record.authenticate(raw_secret)
    assert_not_includes record.attributes.values, raw_secret
  end

  test "verify_and_consume! decrements uses_remaining" do
    record, raw_secret = UserSecret.issue!(name: "API Key", user: @user, uses: 2)

    assert record.verify_and_consume!(raw_secret)
    assert_equal 1, record.reload.uses_remaining
  end

  test "verify_and_consume! marks used when uses_remaining reaches zero" do
    record, raw_secret = UserSecret.issue!(name: "API Key", user: @user, uses: 1)

    assert record.verify_and_consume!(raw_secret)
    assert_equal UserSecretStatus::USED, record.reload.user_secret_status_id
  end

  test "verify_and_consume! expires secrets past their expiry" do
    record, raw_secret = UserSecret.issue!(
      name: "API Key",
      user: @user,
      expires_at: 1.minute.ago,
    )

    assert_not record.verify_and_consume!(raw_secret)
    assert_equal UserSecretStatus::EXPIRED, record.reload.user_secret_status_id
  end

  test "verify_and_consume! only allows one consumer for a single use" do
    record, raw_secret = UserSecret.issue!(name: "API Key", user: @user, uses: 1)
    gate = Queue.new

    futures =
      2.times.map do
        Concurrent::Future.execute do
          ActiveRecord::Base.connection_pool.with_connection do
            gate.pop
            UserSecret.find(record.id).verify_and_consume!(raw_secret)
          end
        end
      end

    2.times { gate << true }
    results = futures.map(&:value!)

    assert_equal 1, results.count(true)
    assert_equal 0, record.reload.uses_remaining
  end

  test "invalid when password_digest is nil" do
    record = UserSecret.new(user: @user, name: "Key", password: nil)
    assert_not record.valid?
    assert_not_empty record.errors[:password_digest]
  end

  test "name length boundary" do
    record = UserSecret.new(user: @user, name: "a" * 256, password: "SecretPass123!")
    assert_not record.valid?
    assert_not_empty record.errors[:name]
  end

  test "association deletion: destroys when user is destroyed" do
    record, _raw = UserSecret.issue!(name: "Cleanup Test", user: @user)
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { record.reload }
  end

  test "generate_raw_secret returns base58 string of expected length" do
    secret = UserSecret.generate_raw_secret(length: 32)

    assert_equal 32, secret.length
    assert_match(/\A[1-9A-HJ-NP-Za-km-z]+\z/, secret)
  end

  test "value maps to password accessor" do
    record = UserSecret.new(user: @user, name: "Key")

    record.value = secure_secret

    assert_equal record.password, record.value
  end

  test "enabled? reflects active status" do
    record = UserSecret.new(user: @user, name: "Key")
    record.user_secret_status_id = "ACTIVE"
    assert_predicate record, :enabled?

    record.user_secret_status_id = "REVOKED"
    assert_not record.enabled?
  end

  private

  def create_secret!
    UserSecret.create!(
      user: @user,
      name: "Secret-#{SecureRandom.hex(4)}",
      password: secure_secret,
      password_confirmation: secure_secret,
    )
  end

  def secure_secret
    SecureRandom.base58(Secret::SECRET_PASSWORD_LENGTH)
  end
end
