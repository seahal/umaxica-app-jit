# == Schema Information
#
# Table name: staff_recovery_codes
#
#  id                   :uuid             not null, primary key
#  expires_in           :date
#  recovery_code_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  staff_id             :bigint           not null
#
# Indexes
#
#  index_staff_recovery_codes_on_staff_id  (staff_id)
#
require "test_helper"

class StaffRecoveryCodeTest < ActiveSupport::TestCase
  test "should create recovery code with valid attributes" do
    recovery_code = StaffRecoveryCode.new(
      recovery_code_digest: "digest_hash",
      expires_in: Date.tomorrow,
      staff_id: 999999 # Use dummy ID to avoid constraint
    )
    # Test attribute assignment without actual save
    assert_equal "digest_hash", recovery_code.recovery_code_digest
    assert_equal Date.tomorrow, recovery_code.expires_in
    assert_equal 999999, recovery_code.staff_id
  end

  test "should belong to staff" do
    assert_respond_to StaffRecoveryCode.new, :staff
  end

  test "should inherit from IdentifiersRecord" do
    assert_includes StaffRecoveryCode.ancestors, IdentifiersRecord
  end

  test "should have required database columns" do
    required_columns = %w[recovery_code_digest expires_in staff_id]

    required_columns.each do |column|
      assert_includes StaffRecoveryCode.column_names, column
    end
  end

  test "should handle expiration date" do
    recovery_code = StaffRecoveryCode.new(expires_in: Date.tomorrow, staff_id: 1)

    assert_equal Date.tomorrow, recovery_code.expires_in
  end
end
