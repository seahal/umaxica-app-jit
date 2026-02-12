# frozen_string_literal: true

# == Schema Information
#
# Table name: users
# Database name: principal
#
#  id                    :bigint           not null, primary key
#  deactivated_at        :datetime
#  last_reauth_at        :datetime
#  lock_version          :integer          default(0), not null
#  multi_factor_enabled  :boolean          default(FALSE), not null
#  purged_at             :datetime
#  scheduled_purge_at    :datetime
#  withdrawal_started_at :datetime
#  withdrawn_at          :datetime         default(Infinity)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  public_id             :string(255)      default(""), not null
#  status_id             :bigint           default(13), not null
#
# Indexes
#
#  index_users_on_deactivated_at         (deactivated_at) WHERE (deactivated_at IS NOT NULL)
#  index_users_on_public_id              (public_id) UNIQUE
#  index_users_on_purged_at              (purged_at) WHERE (purged_at IS NOT NULL)
#  index_users_on_scheduled_purge_at     (scheduled_purge_at) WHERE (scheduled_purge_at IS NOT NULL)
#  index_users_on_status_id              (status_id)
#  index_users_on_withdrawal_started_at  (withdrawal_started_at) WHERE (withdrawal_started_at IS NOT NULL)
#  index_users_on_withdrawn_at           (withdrawn_at) WHERE (withdrawn_at IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => user_statuses.id)
#

class User < PrincipalRecord
  include ::PublicId
  include ::Accountably
  include ::Withdrawable

  # what is this?
  VERIFIED_RECOVERY_EMAIL_STATUS_IDS = [
    UserEmailStatus::VERIFIED,
    UserEmailStatus::VERIFIED_WITH_SIGN_UP,
  ].freeze
  VERIFIED_RECOVERY_TELEPHONE_STATUS_IDS = [
    UserTelephoneStatus::VERIFIED,
    UserTelephoneStatus::VERIFIED_WITH_SIGN_UP,
  ].freeze
  RECOVERY_IDENTITY_REQUIRED_MESSAGE = "パスキー/シークレットを登録するには、先にメールアドレスまたは電話番号を1つ以上登録（確認）してください。"

  # TODO: i want to delete this.
  self.ignored_columns += ["webauthn_id"]

  attribute :status_id, default: UserStatus::NONE

  belongs_to :user_status,
             foreign_key: :status_id,
             inverse_of: :users
  has_one :user_social_apple,
          dependent: :destroy,
          inverse_of: :user
  has_one :user_social_google,
          dependent: :destroy,
          inverse_of: :user
  has_many :user_emails,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_telephones,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_secrets,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_passkeys,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_one_time_passwords,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_audits,
           foreign_key: :subject_id,
           dependent: :destroy,
           inverse_of: false
  has_many :user_tokens,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_memberships,
           dependent: :destroy,
           inverse_of: :user
  has_many :staff_audits,
           as: :actor,
           dependent: :destroy
  has_many :user_messages,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_notifications,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_clients,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_client_discoveries,
           class_name: "UserClientDiscovery",
           dependent: :destroy,
           inverse_of: :user
  has_many :user_client_observations,
           class_name: "UserClientObservation",
           dependent: :destroy,
           inverse_of: :user
  has_many :user_client_revocations,
           class_name: "UserClientRevocation",
           dependent: :destroy,
           inverse_of: :user
  has_many :user_client_impersonations,
           class_name: "UserClientImpersonation",
           dependent: :destroy,
           inverse_of: :user
  has_many :user_client_suspensions,
           class_name: "UserClientSuspension",
           dependent: :destroy,
           inverse_of: :user
  has_many :user_client_deletions,
           class_name: "UserClientDeletion",
           dependent: :destroy,
           inverse_of: :user
  has_many :clients,
           through: :user_clients
  has_many :owned_clients,
           class_name: "Client",
           dependent: :nullify,
           inverse_of: :user
  has_many :avatar_assignments, dependent: :destroy
  has_many :assigned_avatars, through: :avatar_assignments, source: :avatar
  has_many :owned_avatars,
           -> { joins(:avatar_assignments).where(avatar_assignments: { role: "owner" }) },
           through: :avatar_assignments,
           source: :avatar
  validates :public_id, uniqueness: true, length: { maximum: 21 }
  validates :status_id, numericality: { only_integer: true }

  def totp_enabled?
    user_one_time_passwords.exists?(user_one_time_password_status_id: UserOneTimePasswordStatus::ACTIVE)
  end

  def staff?
    false
  end

  def user?
    true
  end

  # Compatibility shim for legacy pluralized callers.
  # Association remains has_one.
  def user_social_googles
    user_social_google ? [user_social_google] : []
  end

  # what is this?
  def has_verified_recovery_identity?
    has_verified_pii?
  end

  def has_verified_pii?
    verified_email? || verified_telephone?
  end

  def login_methods_remaining?(excluding_provider: nil)
    remaining_login_methods(excluding_provider: excluding_provider).any?
  end

  def remaining_login_methods(excluding_provider: nil)
    excluded = excluding_provider.present? ? SocialIdentifiable.normalize_provider(excluding_provider) : nil
    methods = []

    methods << :google if active_social_provider?("google") && excluded != "google"
    methods << :apple if active_social_provider?("apple") && excluded != "apple"
    methods << :email if verified_email?
    methods << :passkey if passkey_login_available?

    methods
  end

  def active_social_provider?(provider)
    normalized = SocialIdentifiable.normalize_provider(provider)
    case normalized
    when "google"
      user_social_google&.user_identity_social_google_status_id == UserSocialGoogleStatus::ACTIVE
    when "apple"
      user_social_apple&.user_identity_social_apple_status_id == UserSocialAppleStatus::ACTIVE
    else
      false
    end
  end

  def verified_email?
    user_emails.exists?(user_email_status_id: VERIFIED_RECOVERY_EMAIL_STATUS_IDS)
  end

  def verified_telephone?
    user_telephones.exists?(user_identity_telephone_status_id: VERIFIED_RECOVERY_TELEPHONE_STATUS_IDS)
  end

  def passkey_login_available?
    return false unless user_passkeys.active.exists?

    verified_telephone?
  end

  def withdrawal_started?
    withdrawal_started_at.present?
  end

  def deactivated?
    deactivated_at.present?
  end

  def withdrawal_in_progress?
    withdrawal_started? || deactivated?
  end
end
