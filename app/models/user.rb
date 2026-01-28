# frozen_string_literal: true

# == Schema Information
#
# Table name: users
# Database name: principal
#
#  id                      :uuid             not null, primary key
#  last_reauth_at          :datetime
#  lock_version            :integer          default(0), not null
#  withdraw_cooldown_until :datetime
#  withdraw_requested_at   :datetime
#  withdraw_scheduled_at   :datetime
#  withdrawn_at            :datetime         default(Infinity)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  public_id               :string(255)      default("")
#  status_id               :string(255)      default("ACTIVE"), not null
#
# Indexes
#
#  index_users_on_public_id                (public_id) UNIQUE
#  index_users_on_status_id                (status_id)
#  index_users_on_withdraw_cooldown_until  (withdraw_cooldown_until)
#  index_users_on_withdraw_scheduled_at    (withdraw_scheduled_at)
#  index_users_on_withdrawn_at             (withdrawn_at) WHERE (withdrawn_at IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => user_statuses.id)
#

class User < PrincipalRecord
  self.ignored_columns += [ "webauthn_id" ]
  include ::PublicId
  include ::Accountably

  attribute :status_id, default: UserStatus::ACTIVE

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
  has_one :passkey,
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
  validates :status_id, length: { maximum: 255 }

  WITHDRAWAL_SCHEDULE_PERIOD = 31.days
  WITHDRAWAL_COOLDOWN_PERIOD = 24.hours

  def totp_enabled?
    user_one_time_passwords.exists?(user_one_time_password_status_id: "ACTIVE")
  end

  def active?
    !pre_withdrawal_condition? && !withdrawn?
  end

  def pre_withdrawal_condition?
    status_id == UserStatus::PRE_WITHDRAWAL_CONDITION
  end

  def withdrawn?
    status_id == UserStatus::WITHDRAWN
  end

  def withdrawal_cooldown_active?(now = Time.current)
    withdraw_cooldown_until.present? && now < withdraw_cooldown_until
  end

  def request_withdrawal!(requested_at: Time.current)
    ensure_withdrawal_requestable!(requested_at)
    apply_withdrawal_request!(requested_at)
  end

  def finalize_withdrawal!(finalized_at: Time.current)
    ensure_withdrawal_finalizable!(finalized_at)
    apply_permanent_withdrawal!(finalized_at)
  end

  def enforce_withdrawal_on_login!(now = Time.current)
    return if active?

    if pre_withdrawal_condition?
      if withdrawal_cooldown_active?(now)
        raise Sign::WithdrawalCooldownError.new(withdraw_cooldown_until: withdraw_cooldown_until)
      end

      apply_permanent_withdrawal!(now)
      raise Sign::WithdrawalFinalizedError.new
    end

    raise Sign::WithdrawalFinalizedError.new if withdrawn?

    raise Sign::InvalidWithdrawalStateError.new(status_id)
  end

  def destroy_withdrawal_account!(now: Time.current)
    ensure_withdrawal_deletable!(now)
    destroy!
  end

  def self.finalize_scheduled_withdrawals!(now = Time.current)
    where(status_id: UserStatus::PRE_WITHDRAWAL_CONDITION)
      .where(withdraw_scheduled_at: ..now)
      .find_each do |user|
        user.send(:apply_permanent_withdrawal!, now)
      end
  end

  def staff?
    false
  end

  def user?
    true
  end

  private

    def ensure_withdrawal_requestable!(now)
      raise Sign::WithdrawalCooldownError.new(withdraw_cooldown_until: withdraw_cooldown_until) if withdrawal_cooldown_active?(now)
      raise Sign::InvalidWithdrawalStateError.new(status_id) unless active?
    end

    def ensure_withdrawal_finalizable!(now)
      raise Sign::WithdrawalCooldownError.new(withdraw_cooldown_until: withdraw_cooldown_until) if withdrawal_cooldown_active?(now)
      raise Sign::InvalidWithdrawalStateError.new(status_id) unless pre_withdrawal_condition?
    end

    def ensure_withdrawal_deletable!(now)
      raise Sign::WithdrawalCooldownError.new(withdraw_cooldown_until: withdraw_cooldown_until) if withdrawal_cooldown_active?(now)
    end

    def apply_withdrawal_request!(requested_at)
      update!(
        status_id: UserStatus::PRE_WITHDRAWAL_CONDITION,
        withdraw_requested_at: requested_at,
        withdraw_scheduled_at: requested_at + WITHDRAWAL_SCHEDULE_PERIOD,
        withdraw_cooldown_until: requested_at + WITHDRAWAL_COOLDOWN_PERIOD,
      )
    end

    def apply_permanent_withdrawal!(finalized_at)
      transaction do
        update!(status_id: UserStatus::WITHDRAWN)
        invalidate_all_sessions!(finalized_at)
      end
    end

    def invalidate_all_sessions!(revoked_at)
      TokenRecord.connected_to(role: :writing) do
        user_tokens.where(revoked_at: nil).update_all(revoked_at: revoked_at) # rubocop:disable Rails/SkipsModelValidations
      end
    end
end
