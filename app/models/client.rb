# == Schema Information
#
# Table name: clients
#
#  id          :uuid             not null, primary key
#  public_id   :string
#  moniker     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status_id   :string(255)      default("NEYO"), not null
#  user_id     :uuid
#  division_id :uuid
#
# Indexes
#
#  index_clients_on_division_id  (division_id)
#  index_clients_on_public_id    (public_id) UNIQUE
#  index_clients_on_status_id    (status_id)
#  index_clients_on_user_id      (user_id)
#

# frozen_string_literal: true

class Client < IdentitiesRecord
  include ::PublicId

  self.implicit_order_column = :created_at

  attribute :status_id, default: ClientIdentityStatus::NEYO

  validates :public_id, uniqueness: true, allow_nil: true
  validates :status_id, length: { maximum: 255 }

  belongs_to :user, optional: true, inverse_of: :owned_clients
  belongs_to :client_identity_status,
             foreign_key: :status_id,
             inverse_of: :clients
  belongs_to :division, optional: true, inverse_of: :clients

  has_many :avatars, dependent: :nullify, inverse_of: :client
  has_many :client_avatar_accesses, dependent: :destroy, inverse_of: :client
  has_many :client_avatar_visibilities, dependent: :destroy, inverse_of: :client
  has_many :client_avatar_oversights, dependent: :destroy, inverse_of: :client
  has_many :client_avatar_extractions, dependent: :destroy, inverse_of: :client
  has_many :client_avatar_impersonations, dependent: :destroy, inverse_of: :client
  has_many :client_avatar_suspensions, dependent: :destroy, inverse_of: :client
  has_many :client_avatar_deletions, dependent: :destroy, inverse_of: :client
  has_many :user_client_discoveries,
           class_name: "UserClientDiscovery",
           dependent: :destroy,
           inverse_of: :client
  has_many :user_client_observations,
           class_name: "UserClientObservation",
           dependent: :destroy,
           inverse_of: :client
  has_many :user_client_revocations,
           class_name: "UserClientRevocation",
           dependent: :destroy,
           inverse_of: :client
  has_many :user_client_impersonations,
           class_name: "UserClientImpersonation",
           dependent: :destroy,
           inverse_of: :client
  has_many :user_client_suspensions,
           class_name: "UserClientSuspension",
           dependent: :destroy,
           inverse_of: :client
  has_many :user_client_deletions,
           class_name: "UserClientDeletion",
           dependent: :destroy,
           inverse_of: :client
  has_many :user_clients, dependent: :destroy
  has_many :users, through: :user_clients
end
