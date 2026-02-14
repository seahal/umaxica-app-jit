# frozen_string_literal: true

module StepUp
  module ConfiguredMethods
    module_function

    def call(subject)
      return [] unless subject

      methods = []
      methods << :email_otp if configured_email?(subject)
      methods << :passkey if configured_passkey?(subject)
      methods << :totp if configured_totp?(subject)
      methods
    end

    def configured_email?(subject)
      return subject.user_emails.exists? if subject.respond_to?(:user_emails)
      return subject.staff_emails.exists? if subject.respond_to?(:staff_emails)

      false
    end

    def configured_passkey?(subject)
      return subject.user_passkeys.exists? if subject.respond_to?(:user_passkeys)
      return subject.staff_passkeys.exists? if subject.respond_to?(:staff_passkeys)

      false
    end

    def configured_totp?(subject)
      if subject.respond_to?(:user_one_time_passwords)
        return subject.user_one_time_passwords.exists?
      end
      return subject.staff_one_time_passwords.exists? if subject.respond_to?(:staff_one_time_passwords)

      false
    end
  end
end
