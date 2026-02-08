# frozen_string_literal: true

class AuthMethodGuard
  VERIFIED_EMAIL_STATUSES = [
    UserEmailStatus::VERIFIED,
    UserEmailStatus::VERIFIED_WITH_SIGN_UP,
  ].freeze
  VERIFIED_TELEPHONE_STATUSES = [
    UserTelephoneStatus::VERIFIED,
    UserTelephoneStatus::VERIFIED_WITH_SIGN_UP,
  ].freeze

  def self.remaining_count(user, excluding: nil)
    count = 0

    if user.respond_to?(:user_social_google)
      google = user.user_social_google
      if google&.user_identity_social_google_status_id == UserSocialGoogleStatus::ACTIVE
        count += 1
        count -= 1 if excluding.is_a?(UserSocialGoogle) && excluding.id == google.id
      end
    end

    if user.respond_to?(:user_social_apple)
      apple = user.user_social_apple
      if apple&.user_identity_social_apple_status_id == UserSocialAppleStatus::ACTIVE
        count += 1
        count -= 1 if excluding.is_a?(UserSocialApple) && excluding.id == apple.id
      end
    end

    if user.respond_to?(:user_emails)
      emails = user.user_emails.where(user_email_status_id: VERIFIED_EMAIL_STATUSES)
      count += emails.count
      if excluding.is_a?(UserEmail) && emails.exists?(id: excluding.id)
        count -= 1
      end
    end

    if user.respond_to?(:user_telephones)
      telephones = user.user_telephones.where(user_identity_telephone_status_id: VERIFIED_TELEPHONE_STATUSES)
      count += telephones.count
      if excluding.is_a?(UserTelephone) && telephones.exists?(id: excluding.id)
        count -= 1
      end
    end

    if user.respond_to?(:user_passkeys)
      passkeys = user.user_passkeys.where(status_id: UserPasskeyStatus::ACTIVE)
      count += passkeys.count
      if excluding.is_a?(UserPasskey) && passkeys.exists?(id: excluding.id)
        count -= 1
      end
    end

    if user.respond_to?(:user_secrets)
      secrets = user.user_secrets.where(user_identity_secret_status_id: UserSecretStatus::ACTIVE)
      count += secrets.count
      if excluding.is_a?(UserSecret) && secrets.exists?(id: excluding.id)
        count -= 1
      end
    end

    [count, 0].max
  end

  def self.last_method?(user, excluding: nil)
    remaining_count(user, excluding: excluding).zero?
  end
end
