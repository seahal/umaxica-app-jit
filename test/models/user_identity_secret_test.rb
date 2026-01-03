# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_secrets
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
#  index_user_identity_secrets_on_expires_at                      (expires_at)
#  index_user_identity_secrets_on_user_id                         (user_id)
#  index_user_identity_secrets_on_user_identity_secret_status_id  (user_identity_secret_status_id)
#

require "test_helper"
require "concurrent"

class UserIdentitySecretTest < ActiveSupport::TestCase
  setup do
    UserIdentityStatus.find_or_create_by!(id: "NEYO")
    # Also need UserIdentitySecretStatus as 'ACTIVE', 'USED', 'EXPIRED' are used in tests
    UserIdentitySecretStatus.find_or_create_by!(id: "ACTIVE")
    UserIdentitySecretStatus.find_or_create_by!(id: "USED")
    UserIdentitySecretStatus.find_or_create_by!(id: "EXPIRED")

    @user =
      User.create!(public_id: "u_#{SecureRandom.hex(8)}") do |u|
        u.status_id = "NEYO"
      end
  end

  test "allows up to the maximum number of secrets per user" do
    UserIdentitySecret::MAX_SECRETS_PER_USER.times do
      create_secret!
    end

    assert_equal UserIdentitySecret::MAX_SECRETS_PER_USER,
                 UserIdentitySecret.where(user: @user).count
  end

  test "rejects creating more than the maximum secrets per user" do
    UserIdentitySecret::MAX_SECRETS_PER_USER.times { create_secret! }

    assert_raises(ActiveRecord::RecordInvalid) { create_secret! }
  end

  test "issue! returns raw secret and persists a digest" do
    record, raw_secret = UserIdentitySecret.issue!(name: "API Key", user: @user)

    assert_predicate record, :persisted?
    assert_predicate raw_secret, :present?
    assert record.authenticate(raw_secret)
    assert_not_includes record.attributes.values, raw_secret
  end

  test "verify_and_consume! decrements uses_remaining" do
    record, raw_secret = UserIdentitySecret.issue!(name: "API Key", user: @user, uses: 2)

    assert record.verify_and_consume!(raw_secret)
    assert_equal 1, record.reload.uses_remaining
  end

  test "verify_and_consume! marks used when uses_remaining reaches zero" do
    record, raw_secret = UserIdentitySecret.issue!(name: "API Key", user: @user, uses: 1)

    assert record.verify_and_consume!(raw_secret)
    assert_equal UserIdentitySecretStatus::USED, record.reload.user_identity_secret_status_id
  end

  test "verify_and_consume! expires secrets past their expiry" do
    record, raw_secret = UserIdentitySecret.issue!(
      name: "API Key",
      user: @user,
      expires_at: 1.minute.ago,
    )

    assert_not record.verify_and_consume!(raw_secret)
    assert_equal UserIdentitySecretStatus::EXPIRED, record.reload.user_identity_secret_status_id
  end

  test "verify_and_consume! only allows one consumer for a single use" do
    record, raw_secret = UserIdentitySecret.issue!(name: "API Key", user: @user, uses: 1)
    gate = Queue.new

    futures =
      2.times.map do
        Concurrent::Future.execute do
          ActiveRecord::Base.connection_pool.with_connection do
            gate.pop
            UserIdentitySecret.find(record.id).verify_and_consume!(raw_secret)
          end
        end
      end

    2.times { gate << true }
    results = futures.map(&:value!)

    assert_equal 1, results.count(true)
    assert_equal 0, record.reload.uses_remaining
  end

  test "invalid when password_digest is nil" do
    record = UserIdentitySecret.new(user: @user, name: "Key", password: nil)
    assert_not record.valid?
    assert_not_empty record.errors[:password_digest]
  end

  test "name length boundary" do
    record = UserIdentitySecret.new(user: @user, name: "a" * 256, password: "SecretPass123!")
    assert_not record.valid?
    assert_not_empty record.errors[:name]
  end

  test "association deletion: destroys when user is destroyed" do
    record, _raw = UserIdentitySecret.issue!(name: "Cleanup Test", user: @user)
    @user.destroy
    assert_raise(ActiveRecord::RecordNotFound) { record.reload }
  end

  private

  def create_secret!
    UserIdentitySecret.create!(
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
