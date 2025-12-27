# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_passkeys
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  description :string           default(""), not null
#  external_id :uuid             not null
#  public_key  :text             not null
#  sign_count  :integer          default(0), not null
#  staff_id    :uuid             not null
#  updated_at  :datetime         not null
#  webauthn_id :binary           not null
#
# Indexes
#
#  index_staff_identity_passkeys_on_staff_id     (staff_id)
#  index_staff_identity_passkeys_on_webauthn_id  (webauthn_id) UNIQUE
#

require "test_helper"

class StaffIdentityPasskeyTest < ActiveSupport::TestCase
  test "should create passkey with valid attributes" do
    passkey = StaffIdentityPasskey.new(
      staff: staffs(:one),
      description: "Staff Passkey",
      public_key: "test_staff_public_key",
      sign_count: 1,
      external_id: SecureRandom.uuid,
      webauthn_id: SecureRandom.random_bytes(32),
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
    required_columns = %w(description public_key sign_count external_id staff_id webauthn_id)

    required_columns.each do |column|
      assert_includes StaffIdentityPasskey.column_names, column
    end
  end

  test "enforces maximum passkeys per staff" do
    staff = staffs(:one)
    relation_stub = Struct.new(:count).new(StaffIdentityPasskey::MAX_PASSKEYS_PER_STAFF)

    StaffIdentityPasskey.stub(:where, relation_stub) do
      extra_passkey = StaffIdentityPasskey.new(
        staff: staff,
        description: "Overflow Staff Key",
        public_key: "overflow-key",
        sign_count: 0,
        external_id: SecureRandom.uuid,
        webauthn_id: SecureRandom.random_bytes(32),
      )

      assert_not extra_passkey.valid?
      assert_includes extra_passkey.errors[:base],
                      "exceeds maximum passkeys per staff (#{StaffIdentityPasskey::MAX_PASSKEYS_PER_STAFF})"
    end
  end
end
