# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id           :uuid             not null, primary key
#  webauthn_id  :string           default(""), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  public_id    :string(255)      default("")
#  status_id    :string(255)      default("NEYO"), not null
#  withdrawn_at :datetime         default("infinity")
#
# Indexes
#
#  index_users_on_public_id     (public_id) UNIQUE
#  index_users_on_status_id     (status_id)
#  index_users_on_withdrawn_at  (withdrawn_at)
#

class User < IdentitiesRecord
  self.implicit_order_column = :created_at
  include ::PublicId
  include ::Accountably

  attribute :status_id, default: UserIdentityStatus::NEYO
  include Withdrawable

  validates :public_id, uniqueness: true, length: { maximum: 21 }
  validates :status_id, length: { maximum: 255 }

  belongs_to :user_identity_status,
             foreign_key: :status_id,
             inverse_of: :users
  has_one :user_identity_social_apple,
          dependent: :destroy,
          inverse_of: :user
  has_one :user_identity_social_google,
          dependent: :destroy,
          inverse_of: :user
  has_many :user_identity_emails,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_identity_telephones,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_identity_secrets,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_identity_passkeys,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_identity_one_time_passwords,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_identity_audits,
           foreign_key: :subject_id,
           dependent: :destroy,
           inverse_of: false
  has_many :user_tokens,
           dependent: :destroy,
           inverse_of: :user
  has_many :user_memberships,
           dependent: :destroy,
           inverse_of: :user
  has_many :staff_identity_audits,
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

  def staff?
    false
  end

  def user?
    true
  end
end
