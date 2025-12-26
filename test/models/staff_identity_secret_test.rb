# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_secrets
#
#  id                              :uuid             not null, primary key
#  staff_id                        :uuid             not null
#  password_digest                 :string           default(""), not null
#  last_used_at                    :datetime         default("-infinity"), not null
#  name                            :string           default(""), not null
#  staff_identity_secret_status_id :string(255)      default("ACTIVE"), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  expires_at                      :datetime         default("infinity"), not null
#  uses_remaining                  :integer          default(1), not null
#
# Indexes
#
#  idx_on_staff_identity_secret_status_id_0999b0c4ae  (staff_identity_secret_status_id)
#  index_staff_identity_secrets_on_expires_at         (expires_at)
#  index_staff_identity_secrets_on_staff_id           (staff_id)
#

require "test_helper"

class StaffIdentitySecretTest < ActiveSupport::TestCase
  setup do
    @staff = staffs(:one)
  end

  test "allows up to the maximum number of secrets per staff" do
    StaffIdentitySecret::MAX_SECRETS_PER_STAFF.times do
      create_secret!
    end

    assert_equal StaffIdentitySecret::MAX_SECRETS_PER_STAFF,
                 StaffIdentitySecret.where(staff: @staff).count
  end

  test "rejects creating more than the maximum secrets per staff" do
    StaffIdentitySecret::MAX_SECRETS_PER_STAFF.times { create_secret! }

    assert_raises(ActiveRecord::RecordInvalid) { create_secret! }
  end

  test "issue! returns raw secret and persists a digest" do
    record, raw_secret = StaffIdentitySecret.issue!(name: "API Key", staff: @staff)

    assert_predicate record, :persisted?
    assert_predicate raw_secret, :present?
    assert record.authenticate(raw_secret)
    assert_not_includes record.attributes.values, raw_secret
  end

  test "verify_and_consume! decrements uses_remaining" do
    record, raw_secret = StaffIdentitySecret.issue!(name: "API Key", staff: @staff, uses: 2)

    assert record.verify_and_consume!(raw_secret)
    assert_equal 1, record.reload.uses_remaining
  end

  test "verify_and_consume! marks used when uses_remaining reaches zero" do
    record, raw_secret = StaffIdentitySecret.issue!(name: "API Key", staff: @staff, uses: 1)

    assert record.verify_and_consume!(raw_secret)
    assert_equal StaffIdentitySecretStatus::USED, record.reload.staff_identity_secret_status_id
  end

  test "verify_and_consume! expires secrets past their expiry" do
    record, raw_secret = StaffIdentitySecret.issue!(
      name: "API Key",
      staff: @staff,
      expires_at: 1.minute.ago,
    )

    assert_not record.verify_and_consume!(raw_secret)
    assert_equal StaffIdentitySecretStatus::EXPIRED, record.reload.staff_identity_secret_status_id
  end

  test "requires name to be present" do
    record = StaffIdentitySecret.new(
      staff: @staff,
      name: "",
      password: "SecretPass123!",
    )

    assert_not record.valid?
    assert record.errors[:name]
  end

  private

  def create_secret!
    StaffIdentitySecret.create!(
      staff: @staff,
      name: "Secret-#{SecureRandom.hex(4)}",
      password: secure_secret,
      password_confirmation: secure_secret,
    )
  end

  def secure_secret
    SecureRandom.base58(Secret::SECRET_PASSWORD_LENGTH)
  end
end
