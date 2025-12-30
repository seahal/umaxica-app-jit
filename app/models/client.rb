# == Schema Information
#
# Table name: clients
#
#  id         :uuid             not null, primary key
#  public_id  :string
#  moniker    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status_id  :string(255)      default("NEYO"), not null
#
# Indexes
#
#  index_clients_on_public_id  (public_id) UNIQUE
#  index_clients_on_status_id  (status_id)
#

# frozen_string_literal: true

class Client < IdentitiesRecord
  include ::PublicId

  attribute :status_id, default: ClientIdentityStatus::NEYO

  validates :status_id, length: { maximum: 255 }

  belongs_to :client_identity_status,
             foreign_key: :status_id,
             inverse_of: :clients
  belongs_to :user, inverse_of: :clients
end
