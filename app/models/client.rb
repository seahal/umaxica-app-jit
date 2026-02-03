# == Schema Information
#
# Table name: clients
# Database name: principal
#
#  id               :bigint           not null, primary key
#  lock_version     :integer          default(0), not null
#  moniker          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  client_status_id :bigint           default(0), not null
#  division_id      :bigint
#  public_id        :string           not null
#  status_id        :bigint           default(5), not null
#  user_id          :bigint
#
# Indexes
#
#  index_clients_on_client_status_id  (client_status_id)
#  index_clients_on_division_id       (division_id)
#  index_clients_on_public_id         (public_id) UNIQUE
#  index_clients_on_status_id         (status_id)
#  index_clients_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_clients_on_client_status_id  (client_status_id => client_statuses.id)
#  fk_clients_on_status_id         (status_id => client_statuses.id)
#  fk_rails_...                    (client_status_id => client_statuses.id)
#  fk_rails_...                    (user_id => users.id) ON DELETE => nullify
#

# frozen_string_literal: true

class Client < PrincipalRecord
  include ::PublicId

  attribute :status_id, default: ClientStatus::NEYO

  belongs_to :user, optional: true, inverse_of: :owned_clients
  belongs_to :client_status,
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
  validates :public_id, uniqueness: true, allow_nil: true
  validates :status_id, numericality: { only_integer: true }
end
