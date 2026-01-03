# frozen_string_literal: true

class EnforceNotNullOnIdentityColumns < ActiveRecord::Migration[8.2]
  def change
    tables = {
      apple_auths: %i(access_token email expires_at name provider refresh_token uid),
      google_auths: %i(access_token email expires_at image_url name provider raw_info refresh_token uid),
      role_assignments: %i(staff_id user_id),
      roles: %i(description key name),
      staff_identity_audits: %i(actor_id actor_type ip_address timestamp),
      staff_identity_emails: %i(address otp_counter otp_private_key staff_id),
      staff_identity_secrets: %i(name password_digest),
      staff_identity_telephones: %i(number otp_counter otp_private_key staff_id),
      staff_passkeys: %i(external_id name public_key sign_count transports user_handle),
      staff_recovery_codes: %i(expires_in recovery_code_digest staff_id),
      staffs: %i(staff_identity_status_id webauthn_id),
      user_identity_audits: %i(actor_id actor_type ip_address timestamp),
      user_identity_emails: %i(address otp_counter otp_private_key user_id),
      user_identity_one_time_passwords: %i(user_identity_one_time_password_status_id),
      user_identity_secrets: %i(name password_digest),
      user_identity_social_apples: %i(email image provider refresh_token token user_id),
      user_identity_social_googles: %i(email image provider refresh_token token user_id),
      user_identity_telephones: %i(number otp_counter otp_private_key user_id),
      user_passkeys: %i(external_id name public_key sign_count transports user_handle),
      users: %i(user_identity_status_id webauthn_id),
    }

    tables.each do |table, columns|
      columns.each do |column|
        change_column_null table, column, false
      end
    end
  end
end
