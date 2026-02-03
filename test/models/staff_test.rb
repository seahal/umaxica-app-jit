# frozen_string_literal: true

# == Schema Information
#
# Table name: staffs
# Database name: operator
#
#  id           :bigint           not null, primary key
#  withdrawn_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  public_id    :string           not null
#  status_id    :bigint           default(2), not null
#
# Indexes
#
#  index_staffs_on_public_id     (public_id) UNIQUE
#  index_staffs_on_status_id     (status_id)
#  index_staffs_on_withdrawn_at  (withdrawn_at) WHERE (withdrawn_at IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => staff_statuses.id)
#

require "test_helper"

class StaffTest < ActiveSupport::TestCase
  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  def setup
    StaffTelephoneStatus.find_or_create_by!(id: StaffTelephoneStatus::UNVERIFIED)
    StaffEmailStatus.find_or_create_by!(id: StaffEmailStatus::UNVERIFIED)
    StaffTokenStatus.find_or_create_by!(id: StaffTokenStatus::ACTIVE)
  end

  # ==========================================================================
  # A. Normal cases (specification compliance)
  # ==========================================================================

  test "public_id is auto-generated when not specified" do
    staff = Staff.create!

    assert_predicate staff.public_id, :present?
  end

  test "auto-generated public_id is exactly 8 characters" do
    staff = Staff.create!

    assert_equal 8, staff.public_id.length
  end

  test "auto-generated public_id is lowercase" do
    staff = Staff.create!

    assert_equal staff.public_id, staff.public_id.downcase
  end

  test "auto-generated public_id contains only allowed characters" do
    staff = Staff.create!
    allowed = Staff::PUBLIC_ID_ALPHABET.chars

    staff.public_id.chars.each do |char|
      assert_includes allowed, char, "Character '#{char}' is not in allowed set"
    end
  end

  test "auto-generated public_id is unique across multiple records" do
    public_ids = 10.times.map { Staff.create!.public_id }

    assert_equal public_ids.uniq.size, public_ids.size
  end

  # ==========================================================================
  # B. Normalization (input equivalence)
  # Tests verify that various input formats are normalized to the same output.
  # This ensures case-insensitivity and tolerance for common formatting.
  # ==========================================================================

  test "normalization: uppercase input is converted to lowercase" do
    staff = Staff.new(public_id: "ABCDEFHJ")
    staff.validate

    assert_equal "abcdefhj", staff.public_id
  end

  test "normalization: lowercase input remains lowercase" do
    staff = Staff.new(public_id: "abcdefhj")
    staff.validate

    assert_equal "abcdefhj", staff.public_id
  end

  test "normalization: mixed case input is converted to lowercase" do
    staff = Staff.new(public_id: "AbCdEfHj")
    staff.validate

    assert_equal "abcdefhj", staff.public_id
  end

  # Hyphen/underscore normalization tests per spec:
  # "ABCD-EFGH" -> "abcdefgh", "abcd_efgh" -> "abcdefgh", " abcd-efgh " -> "abcdefgh"

  test "normalization: ABCD-EFGH with hyphen is normalized to abcdefgh" do
    staff = Staff.new(public_id: "ABCD-EFHJ")
    staff.validate

    assert_equal "abcdefhj", staff.public_id
  end

  test "normalization: abcd_efgh with underscore is normalized to abcdefgh" do
    staff = Staff.new(public_id: "abcd_efhj")
    staff.validate

    assert_equal "abcdefhj", staff.public_id
  end

  test "normalization: leading/trailing whitespace is stripped" do
    staff = Staff.new(public_id: " abcd-efhj ")
    staff.validate

    assert_equal "abcdefhj", staff.public_id
  end

  test "normalization: multiple hyphens and underscores are all removed" do
    staff = Staff.new(public_id: "ab-cd_ef-hj")
    staff.validate

    assert_equal "abcdefhj", staff.public_id
  end

  # ==========================================================================
  # C. Boundary Value Analysis
  # ==========================================================================

  test "boundary: length 7 is invalid" do
    staff = Staff.new(public_id: "abcdefh")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "boundary: length 8 is valid" do
    staff = Staff.new(public_id: "abcdefhj")

    assert_predicate staff, :valid?
  end

  test "boundary: length 9 is invalid" do
    staff = Staff.new(public_id: "abcdefhjk")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  # ==========================================================================
  # D. Equivalence Partitioning
  # ==========================================================================

  test "equivalence: valid set - allowed characters only (8 chars) is valid" do
    staff = Staff.new(public_id: "abcdef23")

    assert_predicate staff, :valid?
  end

  test "equivalence: invalid set - contains forbidden character 'i'" do
    staff = Staff.new(public_id: "abcdifhj")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "equivalence: invalid set - contains forbidden character 'o'" do
    staff = Staff.new(public_id: "abcdofhj")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "equivalence: invalid set - contains forbidden character '0'" do
    staff = Staff.new(public_id: "abcd0fhj")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "equivalence: invalid set - contains forbidden character '1'" do
    staff = Staff.new(public_id: "abcd1fhj")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "equivalence: invalid set - contains forbidden character 's'" do
    staff = Staff.new(public_id: "abcdsfhj")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "equivalence: invalid set - contains forbidden character 'z'" do
    staff = Staff.new(public_id: "abcdzfhj")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "equivalence: invalid set - contains forbidden character 'g'" do
    staff = Staff.new(public_id: "abcdgfhj")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "equivalence: invalid set - valid characters but wrong length" do
    staff = Staff.new(public_id: "abcde")

    assert_not staff.valid?
  end

  # ==========================================================================
  # E. Negative testing (failure modes)
  # ==========================================================================

  test "negative: public_id with '0' is invalid" do
    staff = Staff.new(public_id: "abcd0fgh")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "negative: public_id with 'i' is invalid" do
    staff = Staff.new(public_id: "abcdifgh")

    assert_not staff.valid?
    assert_not_empty staff.errors[:public_id]
  end

  test "negative: duplicate public_id is invalid (uniqueness)" do
    existing_staff = Staff.create!
    duplicate_staff = Staff.new(public_id: existing_staff.public_id)

    assert_not duplicate_staff.valid?
    assert_not_empty duplicate_staff.errors[:public_id]
  end

  test "negative: public_id presence validation is configured" do
    # Verify that the presence validation is configured on the model
    validators = Staff.validators_on(:public_id)
    presence_validator = validators.find { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator) }

    assert_not_nil presence_validator
  end

  # ==========================================================================
  # F. Test determinism - collision retry test
  # ==========================================================================

  test "determinism: collision retry generates different public_id on second attempt" do
    # Create an existing staff first
    existing_staff = Staff.create!
    existing_public_id = existing_staff.public_id

    call_count = 0
    Staff.stub(
      :exists?, ->(conditions) {
                  call_count += 1
                  # First call: simulate collision (return true)
                  # Second call and onwards: no collision (return false)
                  call_count == 1 && conditions[:public_id] == existing_public_id
                },
    ) do
      new_staff = Staff.new
      # Stub generate_public_id to return existing_public_id first, then a different one
      generated_ids = [existing_public_id, "newvalid"]
      new_staff.stub(:generate_public_id, -> { generated_ids.shift || "fallback8" }) do
        new_staff.valid?

        assert_equal "newvalid", new_staff.public_id
      end
    end
  end

  test "determinism: auto-generated public_id does not collide with existing records" do
    # Create multiple staffs and ensure no collision
    10.times { Staff.create! }

    public_ids = Staff.pluck(:public_id)

    assert_equal public_ids.uniq.size, public_ids.size
  end

  # ==========================================================================
  # Existing tests (refactored)
  # ==========================================================================

  test "should be valid with auto-generated public_id" do
    staff = Staff.create!

    assert_predicate staff, :valid?
  end

  test "should have timestamps" do
    staff = Staff.create!

    assert_not_nil staff.created_at
    assert_not_nil staff.updated_at
  end

  test "should have many telephones association" do
    staff = Staff.create!

    assert_equal "staff_id", staff.class.reflect_on_association(:staff_telephones).foreign_key
  end

  test "dependent behaviors for staff associations" do
    assert_equal :restrict_with_error,
                 Staff.reflect_on_association(:staff_emails).options[:dependent]
    assert_equal :restrict_with_error,
                 Staff.reflect_on_association(:staff_telephones).options[:dependent]
    assert_equal :nullify,
                 Staff.reflect_on_association(:staff_audits).options[:dependent]
    assert_equal :nullify,
                 Staff.reflect_on_association(:user_audits).options[:dependent]
    assert_equal :destroy,
                 Staff.reflect_on_association(:staff_secrets).options[:dependent]
    assert_equal :destroy,
                 Staff.reflect_on_association(:staff_tokens).options[:dependent]
    assert_equal :destroy,
                 Staff.reflect_on_association(:staff_messages).options[:dependent]
    assert_equal :destroy,
                 Staff.reflect_on_association(:staff_notifications).options[:dependent]
  end

  test "staff? should return true" do
    staff = Staff.create!

    assert_predicate staff, :staff?
  end

  test "user? should return false" do
    staff = Staff.create!

    assert_not staff.user?
  end

  test "should set default status before creation" do
    staff = Staff.create!

    assert_equal StaffStatus::NEYO, staff.status_id
  end

  test "association deletion: restriction by dependent emails" do
    staff = Staff.create!
    StaffEmail.create!(staff: staff, address: "staff_test@example.com")
    assert_no_difference("Staff.count") do
      assert_not staff.destroy
      assert_not_empty staff.errors[:base]
    end
  end

  test "association deletion: restriction by dependent telephones" do
    staff = Staff.create!
    StaffTelephone.create!(staff: staff, number: "+15559876543")
    assert_no_difference("Staff.count") do
      assert_not staff.destroy
      assert_not_empty staff.errors[:base]
    end
  end

  test "association deletion: destroys dependent staff_tokens" do
    staff = Staff.create!
    token = StaffToken.create!(
      staff: staff,
      refresh_expires_at: 1.day.from_now,
    )
    staff.destroy
    assert_raise(ActiveRecord::RecordNotFound) { token.reload }
  end

  private

  def root_workspace
    Workspace.find_or_create_by!(id: NIL_UUID) do |workspace|
      workspace.name = "Root Workspace"
      workspace.domain = "root.example.com"
      workspace.parent_organization = NIL_UUID
    end
  end
end
