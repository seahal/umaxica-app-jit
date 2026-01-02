# == Schema Information
#
# Table name: clients
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  moniker    :string
#  public_id  :string
#  status_id  :string(255)      default("NEYO"), not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_clients_on_public_id  (public_id) UNIQUE
#  index_clients_on_status_id  (status_id)
#  index_clients_on_user_id    (user_id)
#

# frozen_string_literal: true

class Client < IdentitiesRecord
  include ::PublicId

  self.implicit_order_column = :created_at

  attribute :status_id, default: ClientIdentityStatus::NEYO

  validates :public_id, uniqueness: true, allow_nil: true
  validates :status_id, length: { maximum: 255 }

  belongs_to :client_identity_status,
             foreign_key: :status_id,
             inverse_of: :clients
  belongs_to :user, optional: true, inverse_of: :owned_clients
  has_many :avatars, dependent: :nullify, inverse_of: :client
  has_many :user_clients, dependent: :destroy
  has_many :users, through: :user_clients
end
