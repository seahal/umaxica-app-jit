# == Schema Information
#
# Table name: staff_identity_passkeys
#
#  id          :uuid             not null, primary key
#  description :string           not null
#  public_key  :text             not null
#  sign_count  :bigint           default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  external_id :uuid             not null
#  staff_id    :bigint           not null
#  webauthn_id :binary           not null
#
# Indexes
#
#  index_staff_identity_passkeys_on_staff_id  (staff_id)
#
require "test_helper"

class StaffIdentityPasskeyTest < ActiveSupport::TestCase
  test "should create passkey with valid attributes" do
    passkey = StaffIdentityPasskey.new(
      description: "Staff Passkey",
      public_key: "test_staff_public_key",
      sign_count: 1,
      external_id: SecureRandom.uuid,
      staff_id: 999_999,
      webauthn_id: SecureRandom.random_bytes(32)
    )

    assert_equal "Staff Passkey", passkey.description
    assert_equal "test_staff_public_key", passkey.public_key
    assert_equal 1, passkey.sign_count
  end

  test "should belong to staff" do
    assert_respond_to StaffIdentityPasskey.new, :staff
  end

  test "should have description field" do
    passkey = StaffIdentityPasskey.new(description: "Example Description")

    assert_equal "Example Description", passkey.description
  end

  test "should have public_key field" do
    passkey = StaffIdentityPasskey.new(public_key: "staff_key")

    assert_equal "staff_key", passkey.public_key
  end

  test "should inherit from IdentityRecord" do
    assert_includes StaffIdentityPasskey.ancestors, IdentityRecord
  end

  test "should have required database columns" do
    required_columns = %w[description public_key sign_count external_id staff_id webauthn_id]

    required_columns.each do |column|
      assert_includes StaffIdentityPasskey.column_names, column
    end
  end
end
