# == Schema Information
#
# Table name: client_statuses
# Database name: principal
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_client_identity_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

# frozen_string_literal: true

class ClientStatus < PrincipalRecord
  include StringPrimaryKey

  # Status constants
  NEYO = "NEYO"
  has_many :clients,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :client_status
  validates :id, uniqueness: { case_sensitive: false }
end
