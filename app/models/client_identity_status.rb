# == Schema Information
#
# Table name: client_identity_statuses
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class ClientIdentityStatus < IdentitiesRecord
  include UppercaseId

  has_many :clients,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :client_identity_status

  # Status constants
  NEYO = "NEYO"
end
