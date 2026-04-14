# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_emails
# Database name: operator
#
#  id                             :bigint           not null, primary key
#  address                        :string           default(""), not null
#  address_bidx                   :string
#  address_digest                 :string
#  locked_at                      :datetime
#  notifiable                     :boolean          default(TRUE), not null
#  otp_attempts_count             :integer          default(0), not null
#  otp_counter                    :text             not null
#  otp_expires_at                 :datetime
#  otp_last_sent_at               :datetime
#  otp_private_key                :string           not null
#  promotional                    :boolean          default(TRUE), not null
#  subscribable                   :boolean          default(TRUE), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  public_id                      :string(21)       default(""), not null
#  staff_id                       :bigint           not null
#  staff_identity_email_status_id :bigint           default(6), not null
#
# Indexes
#
#  index_staff_emails_on_address                         (address)
#  index_staff_emails_on_address_bidx                    (address_bidx) UNIQUE WHERE (address_bidx IS NOT NULL)
#  index_staff_emails_on_address_digest                  (address_digest) UNIQUE WHERE (address_digest IS NOT NULL)
#  index_staff_emails_on_lower_address                   (lower((address)::text)) UNIQUE
#  index_staff_emails_on_public_id                       (public_id) UNIQUE
#  index_staff_emails_on_staff_id                        (staff_id)
#  index_staff_emails_on_staff_identity_email_status_id  (staff_identity_email_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_identity_email_status_id => staff_email_statuses.id)
#

require "test_helper"

class StaffEmailTest < ActiveSupport::TestCase
  fixtures :staffs, :staff_statuses, :staff_email_statuses

  setup do
    @staff = Staff.find_by!(public_id: "CDEF2345GHJK67NM")
    @valid_attributes = {
      address: "staff@example.com",
      confirm_policy: true,
      staff: @staff,
    }.freeze
  end

  # Basic model structure tests
  test "should inherit from PrincipalRecord" do
    assert_operator StaffEmail, :<, OperatorRecord
  end

  test "should include Email concern" do
    assert_includes StaffEmail.included_modules, Email
  end

  # Email concern validation tests
  test "should be valid with valid email and policy confirmation" do
    staff_email = StaffEmail.new(@valid_attributes)

    assert_predicate staff_email, :valid?
  end

  test "should require valid email format" do
    staff_email = StaffEmail.new(@valid_attributes.merge(address: "invalid-email"))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:address], :any?
  end

  test "should require email presence" do
    staff_email = StaffEmail.new(@valid_attributes.except(:address))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:address], :any?
  end

  test "should require policy confirmation" do
    staff_email = StaffEmail.new(@valid_attributes.merge(confirm_policy: false))

    assert_not staff_email.valid?
    assert_predicate staff_email.errors[:confirm_policy], :any?
  end

  test "should require unique email addresses" do
    StaffEmail.create!(@valid_attributes)
    duplicate_email = StaffEmail.new(@valid_attributes)

    assert_not duplicate_email.valid?
    assert_predicate duplicate_email.errors[:address], :any?
  end

  test "should downcase email address before saving" do
    staff_email = StaffEmail.new(@valid_attributes.merge(address: "STAFF@EXAMPLE.COM"))
    staff_email.save!

    assert_equal "staff@example.com", staff_email.address
  end

  test "should assign numeric id before creation" do
    staff_email = StaffEmail.new(@valid_attributes)

    assert_nil staff_email.id
    staff_email.save!

    assert_not_nil staff_email.id
    assert_kind_of Integer, staff_email.id
  end

  # Encryption tests
  test "should encrypt email address" do
    staff_email = StaffEmail.create!(@valid_attributes)
    # The address should be encrypted in the database
    query = "SELECT address FROM #{StaffEmail.table_name} WHERE id = '#{staff_email.id}'"
    raw_data = StaffEmail.connection.execute(query).first
    assert_not_equal @valid_attributes[:address], raw_data["address"] if raw_data
  end

  test "assigns placeholder staff_id when missing" do
    staff_email = StaffEmail.new(@valid_attributes.except(:staff))
    staff_email.valid?

    assert_equal 0, staff_email.staff_id
  end

  test "to_param uses public_id" do
    staff_email = StaffEmail.create!(@valid_attributes)

    assert_equal staff_email.public_id, staff_email.to_param
  end

  test "blocks destroying an oauth-linked email" do
    staff_email = StaffEmail.create!(@valid_attributes.merge(staff_identity_email_status_id: StaffEmailStatus::OAUTH_LINKED))

    assert_raises(ActiveRecord::RecordNotDestroyed) { staff_email.destroy! }
    assert_includes staff_email.errors[:base], "cannot delete a protected email address"
    assert_equal StaffEmailStatus::OAUTH_LINKED, staff_email.reload.staff_identity_email_status_id
  end

  test "enforces maximum emails per staff" do
    staff = Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))
    Prosopite.pause do
      StaffEmail::MAX_EMAILS_PER_STAFF.times do |i|
        StaffEmail.create!(
          address: "staff_limit#{i}@example.com",
          confirm_policy: true,
          staff: staff,
        )
      end
    end

    extra_email = StaffEmail.new(
      address: "overflow_staff@example.com",
      confirm_policy: true,
      staff: staff,
    )

    assert_not extra_email.valid?
    assert_includes extra_email.errors[:base], "exceeds maximum emails per staff (#{StaffEmail::MAX_EMAILS_PER_STAFF})"
  end

  # Boundary: one below the limit - creation must succeed
  test "allows creating emails up to one below the limit" do
    staff = Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))
    below_limit = StaffEmail::MAX_EMAILS_PER_STAFF - 1

    Prosopite.pause do
      (below_limit - 1).times do |i|
        StaffEmail.create!(
          address: "staff-below#{i}@example.com",
          confirm_policy: true,
          staff: staff,
        )
      end
    end

    email_at_below_limit = StaffEmail.new(
      address: "staff-at-below-limit@example.com",
      confirm_policy: true,
      staff: staff,
    )

    assert_predicate email_at_below_limit, :valid?
  end

  # Boundary: exactly at the limit - the final permitted creation must succeed
  test "allows creating the email that reaches the limit" do
    staff = Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))
    limit = StaffEmail::MAX_EMAILS_PER_STAFF

    Prosopite.pause do
      (limit - 1).times do |i|
        StaffEmail.create!(
          address: "staff-filling#{i}@example.com",
          confirm_policy: true,
          staff: staff,
        )
      end
    end

    last_permitted = StaffEmail.new(
      address: "staff-last-permitted@example.com",
      confirm_policy: true,
      staff: staff,
    )

    assert_predicate last_permitted, :valid?
    assert_nothing_raised { last_permitted.save! }
  end

  # Equivalence: limit is counted per staff member - another staff is unaffected
  test "email limit is isolated per staff" do
    saturated_staff = Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))
    other_staff     = @staff

    Prosopite.pause do
      StaffEmail::MAX_EMAILS_PER_STAFF.times do |i|
        StaffEmail.create!(
          address: "staff-saturated#{i}@example.com",
          confirm_policy: true,
          staff: saturated_staff,
        )
      end
    end

    email_for_other = StaffEmail.new(
      address: "other-staff@example.com",
      confirm_policy: true,
      staff: other_staff,
    )

    assert_predicate email_for_other, :valid?
  end

  # Equivalence: limit validation only fires on create, not on update
  test "email limit is not checked on update" do
    staff = Staff.create!(staff_status: StaffStatus.find(StaffStatus::NOTHING))

    Prosopite.pause do
      StaffEmail::MAX_EMAILS_PER_STAFF.times do |i|
        StaffEmail.create!(
          address: "staff-update-test#{i}@example.com",
          confirm_policy: true,
          staff: staff,
        )
      end
    end

    existing = StaffEmail.where(staff: staff).first
    existing.notifiable = false

    assert_predicate existing, :valid?
    assert_nothing_raised { existing.save! }
  end
end
