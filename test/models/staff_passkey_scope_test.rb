# frozen_string_literal: true

require "test_helper"

class StaffPasskeyScopeTest < ActiveSupport::TestCase
  setup do
    @staff = Staff.create!(public_id: "abcdefhj", status_id: StaffStatus::NEYO)

    @active_passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "active_staff_id",
      external_id: SecureRandom.uuid,
      public_key: "pk",
      description: "Active Key",
      status_id: StaffPasskeyStatus::ACTIVE,
    )

    @inactive_passkey = StaffPasskey.create!(
      staff: @staff,
      webauthn_id: "inactive_staff_id",
      external_id: SecureRandom.uuid,
      public_key: "pk",
      description: "Inactive Key",
      status_id: StaffPasskeyStatus::REVOKED,
    )
  end

  test "active scope includes only active passkeys" do
    assert_includes StaffPasskey.active, @active_passkey
    assert_not_includes StaffPasskey.active, @inactive_passkey
  end
end
