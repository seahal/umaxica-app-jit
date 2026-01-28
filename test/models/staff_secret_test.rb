# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_secrets
# Database name: operator
#
#  id                              :uuid             not null, primary key
#  expires_at                      :datetime         default(Infinity), not null
#  last_used_at                    :datetime         default(-Infinity), not null
#  name                            :string           default(""), not null
#  password_digest                 :string           default(""), not null
#  uses_remaining                  :integer          default(1), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  staff_id                        :uuid             not null
#  staff_identity_secret_status_id :string(255)      default("ACTIVE"), not null
#  staff_secret_kind_id            :string(255)      not null
#
# Indexes
#
#  index_staff_secrets_on_expires_at                       (expires_at)
#  index_staff_secrets_on_staff_id                         (staff_id)
#  index_staff_secrets_on_staff_identity_secret_status_id  (staff_identity_secret_status_id)
#  index_staff_secrets_on_staff_secret_kind_id             (staff_secret_kind_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_identity_secret_status_id => staff_secret_statuses.id)
#  fk_rails_...  (staff_secret_kind_id => staff_secret_kinds.id)
#

require "test_helper"

class StaffSecretTest < ActiveSupport::TestCase
  setup do
    # Set up StaffSecretKind records (lifetime-based)
    StaffSecretKind.find_or_create_by!(id: "UNLIMITED")
    StaffSecretKind.find_or_create_by!(id: "ONE_TIME")
    StaffSecretKind.find_or_create_by!(id: "TIME_BOUND")

    @staff = Staff.find_by!(public_id: "bcde3456")
  end

  test "allows up to the maximum number of secrets per staff" do
    StaffSecret::MAX_SECRETS_PER_STAFF.times do
      create_secret!
    end

    assert_equal StaffSecret::MAX_SECRETS_PER_STAFF,
                 StaffSecret.where(staff: @staff).count
  end

  test "rejects creating more than the maximum secrets per staff" do
    StaffSecret::MAX_SECRETS_PER_STAFF.times { create_secret! }

    assert_raises(ActiveRecord::RecordInvalid) { create_secret! }
  end

  test "issue! returns raw secret and persists a digest" do
    record, raw_secret = StaffSecret.issue!(name: "API Key", staff: @staff, staff_secret_kind_id: "UNLIMITED")

    assert_predicate record, :persisted?
    assert_predicate raw_secret, :present?
    assert record.authenticate(raw_secret)
    assert_not_includes record.attributes.values, raw_secret
  end

  test "verify_and_consume! decrements uses_remaining" do
    record, raw_secret = StaffSecret.issue!(name: "API Key", staff: @staff, uses: 2, staff_secret_kind_id: "UNLIMITED")

    assert record.verify_and_consume!(raw_secret)
    assert_equal 1, record.reload.uses_remaining
  end

  test "verify_and_consume! marks used when uses_remaining reaches zero" do
    record, raw_secret = StaffSecret.issue!(name: "API Key", staff: @staff, uses: 1, staff_secret_kind_id: "UNLIMITED")

    assert record.verify_and_consume!(raw_secret)
    assert_equal StaffSecretStatus::USED, record.reload.staff_secret_status_id
  end

  test "verify_and_consume! expires secrets past their expiry" do
    record, raw_secret = StaffSecret.issue!(
      name: "API Key",
      staff: @staff,
      expires_at: 1.minute.ago,
      staff_secret_kind_id: "UNLIMITED",
    )

    assert_not record.verify_and_consume!(raw_secret)
    assert_equal StaffSecretStatus::EXPIRED, record.reload.staff_secret_status_id
  end

  test "requires name to be present" do
    record = StaffSecret.new(
      staff: @staff,
      name: "",
      password: "SecretPass123!",
    )

    assert_not record.valid?
    assert record.errors[:name]
  end

  test "validates kind_id is required" do
    record = StaffSecret.new(
      staff: @staff,
      name: "Test Secret",
      password: secure_secret,
      staff_secret_kind_id: nil,
    )
    assert_not record.valid?
    assert_not_empty record.errors[:staff_secret_kind]
  end

  test "unlimited? predicate returns true for UNLIMITED kind" do
    record = StaffSecret.new(staff: @staff, name: "Key", staff_secret_kind_id: "UNLIMITED")
    assert_predicate record, :unlimited?
    assert_not record.one_time?
    assert_not record.time_bound?
  end

  test "one_time? predicate returns true for ONE_TIME kind" do
    record = StaffSecret.new(staff: @staff, name: "Key", staff_secret_kind_id: "ONE_TIME")
    assert_predicate record, :one_time?
    assert_not record.unlimited?
    assert_not record.time_bound?
  end

  test "time_bound? predicate returns true for TIME_BOUND kind" do
    record = StaffSecret.new(staff: @staff, name: "Key", staff_secret_kind_id: "TIME_BOUND")
    assert_predicate record, :time_bound?
    assert_not record.unlimited?
    assert_not record.one_time?
  end

  private

    def create_secret!
      StaffSecret.create!(
        staff: @staff,
        name: "Secret-#{SecureRandom.hex(4)}",
        password: secure_secret,
        password_confirmation: secure_secret,
        staff_secret_kind_id: "UNLIMITED",
      )
    end

    def secure_secret
      SecureRandom.base58(Secret::SECRET_PASSWORD_LENGTH)
    end
end
