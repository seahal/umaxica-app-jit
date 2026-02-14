# frozen_string_literal: true

module UserHelpers
  # Helper to create a user with a verified email for tests requiring this prerequisite.
  def create_verified_user_with_email(email_address: "test@example.com", status: UserStatus::NEYO)
    user = User.create!(
      status_id: status, public_id: SecureRandom.hex(10), created_at: Time.current,
      updated_at: Time.current,
    )
    UserEmail.create!(
      user: user,
      address: email_address,
      user_email_status_id: UserEmailStatus::VERIFIED, # Using the confirmed ID for VERIFIED
      created_at: Time.current,
      updated_at: Time.current,
    )
    user # Return the user object
  end
end

ActiveSupport.on_load(:active_support_test_case) { include UserHelpers }
