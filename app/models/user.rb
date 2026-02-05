# frozen_string_literal: true

# == Schema Information
#
# Table name: users
# Database name: principal
#
#  id                   :bigint           not null, primary key
#  last_reauth_at       :datetime
#  lock_version         :integer          default(0), not null
#  multi_factor_enabled :boolean          default(FALSE), not null
#  withdrawn_at         :datetime         default(Infinity)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  public_id            :string(255)      default(""), not null
#  status_id            :bigint           default(13), not null
#
# Indexes
#
#  index_users_on_public_id     (public_id) UNIQUE
#  index_users_on_status_id     (status_id)
#  index_users_on_withdrawn_at  (withdrawn_at) WHERE (withdrawn_at IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => user_statuses.id)
#

class User < PrincipalRecord
  self.ignored_columns += ["webauthn_id"]
  include ::PublicId
  include ::Accountably
  include ::Withdrawable

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
end
