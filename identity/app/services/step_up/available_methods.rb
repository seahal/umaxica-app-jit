# typed: false
# frozen_string_literal: true

module StepUp
  module AvailableMethods
    module_function

    def call(subject)
      return [] unless subject

      methods = []
      methods << :email_otp if usable_email?(subject)
      methods << :passkey if usable_passkey?(subject)
      methods << :totp if usable_totp?(subject)
      methods
    end

    def usable_email?(subject)
      if subject.respond_to?(:user_emails)
        return subject.user_emails.exists?(user_email_status_id: AuthMethodGuard::VERIFIED_EMAIL_STATUSES)
      end

      if subject.respond_to?(:customer_emails)
        return subject.customer_emails.exists?(customer_email_status_id: AuthMethodGuard::CUSTOMER_VERIFIED_EMAIL_STATUSES)
      end

      if subject.respond_to?(:staff_emails)
        return subject.staff_emails.exists?(
          staff_identity_email_status_id: [
            StaffEmailStatus::ACTIVE,
            StaffEmailStatus::VERIFIED,
          ],
        )
      end

      false
    end

    def usable_passkey?(subject)
      return subject.user_passkeys.active.exists? if subject.respond_to?(:user_passkeys)
      return subject.customer_passkeys.active.exists? if subject.respond_to?(:customer_passkeys)
      return subject.staff_passkeys.active.exists? if subject.respond_to?(:staff_passkeys)

      false
    end

    def usable_totp?(subject)
      if subject.respond_to?(:user_one_time_passwords)
        return subject.user_one_time_passwords.exists?(
          user_identity_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE,
        )
      end

      false
    end
  end
end
