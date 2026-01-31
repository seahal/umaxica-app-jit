# frozen_string_literal: true

require "test_helper"

class UserPasskeyScopeTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(public_id: "u_#{SecureRandom.hex(8)}", status_id: "NEYO")

    @active_passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: "active_id",
      external_id: SecureRandom.uuid,
      public_key: "pk",
      description: "Active Key",
      user_passkey_status_id: UserPasskeyStatus::ACTIVE,
    )

    @inactive_passkey = UserPasskey.create!(
      user: @user,
      webauthn_id: "inactive_id",
      external_id: SecureRandom.uuid,
      public_key: "pk",
      description: "Inactive Key",
      user_passkey_status_id: UserPasskeyStatus::DISABLED,
    )
  end

  test "active scope includes only active passkeys" do
    assert_includes UserPasskey.active, @active_passkey
    assert_not_includes UserPasskey.active, @inactive_passkey
  end
end
