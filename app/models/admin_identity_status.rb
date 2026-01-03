# frozen_string_literal: true

class AdminIdentityStatus < IdentitiesRecord
  include UppercaseId

  has_many :admins,
           foreign_key: :status_id,
           inverse_of: :admin_identity_status,
           dependent: :restrict_with_error

  # Status constants
  NEYO = "NEYO"

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
